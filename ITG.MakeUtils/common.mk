#!/usr/bin/make

ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

#region info, warning and error wrappers

# $(call writeinformation, msg, details)
writeinformationaux ?=

writeinformationauxII ?= \
  $(info $(1)) \
  $(info $(2))
#writeinformationauxII ?= \
#  Write-Information '$(1)';

writeinformation = \
  $(call writeinformationaux,$(1),$(2)) \
  $(call writeinformationauxII,$(1),$(2))

# $(call writewarning, msg, details)
writewarningaux ?=

writewarningauxII ?= \
  $(warning $(1)) \
  $(info $(2))
#writewarningauxII ?= \
#  Write-Warning '$(1)';

writewarning = \
  $(call writewarningaux,$(1),$(2)) \
  $(call writewarningauxII,$(1),$(2))

# $(call writeerror, msg, details)
writeerroraux ?=

writeerrorauxII ?= \
  $(error $(1)) \
  $(info $(2))
#writeerrorauxII ?= \
#  Write-Error '$(1)';

writeerror = \
  $(call writeerroraux,$(1),$(2)) \
  $(call writeerrorauxII,$(1),$(2))

#endregion info, warning and error wrappers

#region calc ITG.MakeUtils relative path
ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(patsubst $(abspath $(ROOT_PROJECT_DIR))%,$$(ROOT_PROJECT_DIR)%,$(abspath $(MAKE_COMMON_DIR)))
#endregion calc ITG.MakeUtils relative path

include $(MAKE_COMMON_DIR)GMSL/gmsl
__itg_makeutils_included:=$(true)

include $(MAKE_COMMON_DIR)help-system.mk

#region check make tool version and features

#ifeq ($(call set_is_member,oneshell,$(call set_create,$(.FEATURES))),$(false))
#$(call writeerror,Requires make version that supports .ONESHELL feature.)
#endif

ifneq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
$(call writeerror,Requires make version 3.82 or higher.)
endif

#endregion check make tool version and features

#region symbols

COMMA              :=,
LEFT_BRACKET       :=(
RIGHT_BRACKET      :=)

ifeq ($(OS),Windows_NT)
PATHSEP            :=;
else
PATHSEP            :=:
endif

#endregion symbols

#region deprecated functions wrappers

ifeq ($(need-help),$(false))

# $(call _deprecated_function, function, replacement)
_deprecated_function = $(call writewarning,Function $1 is deprecated.$(if $2, Please$(COMMA) see about $2.))

# $(call _obsolete_function, function, replacement)
_obsolete_function = $(call writeerror,Function $1 is not avaliable now. It is obsolete.$(if $2, Please$(COMMA) see about $2.))

endif

#endregion deprecated functions wrappers

#region debug support

ifdef DEBUG_TRACE

_debug_enter = $(info Entering $0($(_args)))

_debug_leave = $(info Leaving $0)

_args = $(subst $(__gmsl_space),$(COMMA) ,$(strip $(foreach a,1 2 3 4 5 6 7 8 9,$($a))))

endif

#endregion debug support

.SECONDARY::;
.SECONDEXPANSION::;
.DELETE_ON_ERROR::;

#region obsolete cygpath related functions
winPath = $(call _obsolete_function,winPath)$(shell cygpath -w $1)
shellPath = $(call _obsolete_function,shellPath)$(shell cygpath -u $1)
OSPath = $(call _obsolete_function,OSPath)$1
OSabsPath = $(call _deprecated_function,OSabsPath)$(abspath $1)
#endregion obsolete cygpath related functions

#region setup shell

SHELLTYPE := sh

ifeq ($(OS),Windows_NT)
  ifeq (a,$(shell echo "a"))
    ISCYGWIN := $(true)
    MAKE := make
    OSabsPath = $(call _deprecated_function,OSabsPath)$(shell cygpath -m $(abspath $1))
  else
    ISCYGWIN := $(false)
  endif
  HIDE := attrib +h
  UNHIDE := attrib -h
else
  ISCYGWIN := $(false)
  HIDE := /dev/null <
  UNHIDE := /dev/null <
endif

VERBOSE            ?= true

MKDIR              := mkdir -p
MAKETARGETDIR      = $(MKDIR) $(@D)
MAKETARGETASDIR    = $(MKDIR) $@
RMDIR              := rm -r -f
RM                 := rm -r -f
TOUCH              := touch
HIDETARGET         = $(HIDE) $@
UNHIDETARGET       = $(UNHIDE) $@
COPY               := cp
CURL               := curl

DIRMARKERFILE      := .dirstate

%/$(DIRMARKERFILE):
	$(MAKETARGETDIR)
	@$(TOUCH) $@
	@$(HIDE) $@

TARGETDIR = $(if $1,$(dir $1)$(DIRMARKERFILE),$$(@D)/$(DIRMARKERFILE))

# $(call dirname,dir)
dirname = $(patsubst %/,%,$1)

#endregion setup shell

#region common dirs

AUXDIR             ?= obj/
OUTPUTDIR          ?= release/
SOURCESDIR         ?= sources/
CONFIGDIR          ?= config/

#endregion common dirs

is_configure_target:=$(call set_is_member,configure,$(call set_create,$(MAKECMDGOALS)))
is_clean_target:=$(call __gmsl_make_bool,$(filter %clean,$(MAKECMDGOALS)))
is_check_target:=$(call __gmsl_make_bool,$(filter check% test%,$(MAKECMDGOALS)))
is_config_target:=$(call set_is_member,.GLOBAL_VARIABLES,$(call set_create,$(MAKECMDGOALS)))
is_productive_target:=$(call and,$(call not,$(is_clean_target)),$(call not,$(is_config_target)),$(call not,$(is_configure_target)))

is_root_project:=$(false)
ifdef ROOT_PROJECT_DIR
  ifeq ($(ROOT_PROJECT_DIR),./)
    is_root_project:=$(true)
  endif
endif

# $(call rwildcard,dir,filesfilter)
rwildcard = $(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))

# $(call include_makefile,makefile)
define include_makefile
$(call assert,$1,Expected makefile name)
include $1

endef

# $(call include_makefile_if_not_clean,makefile)
define include_makefile_if_not_clean
$(call assert,$1,Expected makefile name)
$(if $(call not,$(is_clean_target)),$(call include_makefile,$1))
endef

# $(call include_build_makefile,makefile)
define include_build_makefile
$(call assert,$1,Expected makefile name)
$(if $(is_productive_target),$(call include_makefile,$1))
endef

# $(call include_check_makefile,makefile)
define include_check_makefile
$(call assert,$1,Expected makefile name)
$(if $(is_check_target),$(call include_makefile,$1))
endef


AUX_MAKEFILE_LIST:=$(empty_set)

__itg_get_static_makefile_list=$(call set_remove,$(AUX_MAKEFILE_LIST),$(call set_create,$(MAKEFILE_LIST)))

__itg_aux_makefile=$(call merge,,$(if $2,$2,$(AUXDIR)) $1)

# $(call call_as_makefile,expression,makefile,makefile_dir,deps)
define __call_as_makefile_aux

$(call __itg_aux_makefile,$2,$3): $(call __itg_get_static_makefile_list) $4 | $$(TARGETDIR)
	$$(file > $$@,#!/usr/bin/make)
	$$(file >> $$@,)
	$$(file >> $$@,$1)
	$$(TOUCH) $$@

AUX_MAKEFILE_LIST:=$(call __itg_aux_makefile,$2,$3) $$(AUX_MAKEFILE_LIST)

endef

ifeq ($(is_configure_target),$(true))

define call_as_makefile
$(call assert,$2,Expected makefile name)
$(call __call_as_makefile_aux,$1,$2,$(if $3,$3,$(CONFIGDIR)),$4)
configure:: $(call __itg_aux_makefile,$2,$(if $3,$3,$(CONFIGDIR)))

endef

else

ifeq ($(is_productive_target),$(true))

define call_as_makefile

AUX_MAKEFILE_LIST:=$(call __itg_aux_makefile,$2,$3) $$(AUX_MAKEFILE_LIST)

$(call include_makefile,$(call __itg_aux_makefile,$2,$(if $3,$3,$(CONFIGDIR))))

endef

else
  call_as_makefile=
endif

endif

# $(call call_as_check_makefile,expression,makefile,makefile_dir,deps)
ifeq ($(is_check_target),$(true))

define call_as_check_makefile
$(call assert,$2,Expected makefile name)
$(call __call_as_makefile_aux,$1,$2,$3,$4)
$(call include_makefile,$(call __itg_aux_makefile,$2,$3))
endef

endif

# $(call call_as_build_makefile,expression,makefile,makefile_dir,deps)
ifeq ($(is_productive_target),$(true))

define call_as_build_makefile
$(call assert,$2,Expected makefile name)
$(call __call_as_makefile_aux,$1,$2,$3,$4)
$(call include_makefile,$(call __itg_aux_makefile,$2,$3))
endef

endif


# $(call reversedirpath,dirPath,pathToRootFromChild)
reversedirpath = $(if $(strip $1),$(call merge,/,$(foreach d,$(call split,/,$1),..))/,./)

# $(call setvariable, var, value)
define setvariable
$1:=$2

endef

ifeq ($(call or,$(is_productive_target),$(is_configure_target)),$(true))

# $(call copy_file, to, from)
define copy_file
$(call assert,$1,Expected file name (to))
$(call assert,$2,Expected file name (from))
$1: $2 | $$(TARGETDIR)
	$(COPY) $$< $$@
endef

else
  copy_file=
endif

# $(call copy_file_to, todir, fromfile)
copy_file_to = $(call copy_file,$1$(notdir $2),$2)

# $(call copy_file_from, tofile, fromdir)
copy_file_from = $(call copy_file,$1,$2$(notdir $1))

#region subprojects support

SUBPROJECTS_EXPORTS_DIR := $(CONFIGDIR)subprojectExports/

SUBPROJECT_EXPORTS_FILE ?= $(SUBPROJECTS_EXPORTS_DIR)undefined

.PHONY: .GLOBAL_VARIABLES
.GLOBAL_VARIABLES: $(SUBPROJECT_EXPORTS_FILE)
$(SUBPROJECT_EXPORTS_FILE):: $(call __itg_get_static_makefile_list) | $(TARGETDIR)
	$(file > $@,# subproject exported variables)

# $(call exportGlobalVariablesAux, Variables, Writer)
define exportGlobalVariablesAux
$(SUBPROJECT_EXPORTS_FILE)::
	$(foreach var,$(1),$$(file >> $$@,export $(var)=$(call $(2),$(var))))

endef

# $(call exportGlobalVariables, Variables)
SimpleVariableWriter = $$($(1))
exportGlobalVariables = $(call exportGlobalVariablesAux,$(1),SimpleVariableWriter)
exportGlobalVariable = $(exportGlobalVariables)

# $(call pushArtifactTargets, Variables)
TargetWriter = $$(foreach path,$$($(1)),$$$$$$$$(ROOT_PROJECT_DIR)$(SUBPROJECT_DIR)$$(path))
pushArtifactTargets = $(call exportGlobalVariablesAux,$(1),TargetWriter)
pushArtifactTarget = $(pushArtifactTargets)

# $(call getSubProjectDir, Project)
getSubProjectDir = $(call assert,$1,Expected project slug)$($(1)_DIR)

# $(call setSubProjectDir, Project, ProjectDir)
define setSubProjectDir
$(call assert,$1,Expected project slug)
$(call assert,$2,Expected project directory path)
export $(1)_DIR := $2/
endef

# $(call MAKE_SUBPROJECT, Project)
MAKE_SUBPROJECT = \
  $(MAKE) \
    -C $(call getSubProjectDir,$1) \
    SUBPROJECT=$1 \
    SUBPROJECT_DIR=$(call getSubProjectDir,$1) \
    ROOT_PROJECT_DIR=$(call reversedirpath,$(call getSubProjectDir,$1)) \
    SUBPROJECT_EXPORTS_FILE=$(call reversedirpath,$1)$(SUBPROJECTS_EXPORTS_DIR)$1.mk

# $(call MAKE_SUBPROJECT_TARGET, Target)
MAKE_SUBPROJECT_TARGET = \
  $(MAKE) \
    -C $(ROOT_PROJECT_DIR) \
    ROOT_PROJECT_DIR=./ \
    $1

# $(call declareProjectTargets, Project)
define declareProjectTargets
$(call assert,$1,Expected project slug)
$(call getSubProjectDir,$1)%:
	$(call MAKE_SUBPROJECT,$1) $$*
endef

# $(call useSubProject, SubProject, SubProjectDir [, Targets ])
define useSubProject
$(call assert,$1,Expected project slug)
$(call assert,$2,Expected project directory path)
$(eval $(call setSubProjectDir,$1,$2))
$(SUBPROJECTS_EXPORTS_DIR)$1.mk: $(call getSubProjectDir,$1)Makefile | $$(TARGETDIR)
	$(call MAKE_SUBPROJECT,$1) .GLOBAL_VARIABLES
.PHONY: $1 $3
$(call include_makefile_if_not_clean,$(SUBPROJECTS_EXPORTS_DIR)$1.mk)
$1:
	$(call MAKE_SUBPROJECT,$1)
test-$1:
	$(call MAKE_SUBPROJECT,$1) --keep-going check
$3:
	$(call MAKE_SUBPROJECT,$1) $$@
$(foreach target,$3,test-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(foreach target,$3,test.%-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(call getSubProjectDir,$1)%:
	$(call MAKE_SUBPROJECT,$1) $$*
configure::
	$(call MAKE_SUBPROJECT,$1) $$@
all:: $1
check: test-$1
help::
	@$(call MAKE_SUBPROJECT,$1) -s --no-print-directory help
ifeq ($(filter clean distclean maintainer-clean,$(MAKECMDGOALS)),)
mostlyclean::
	$(call MAKE_SUBPROJECT,$1) mostlyclean
endif
ifeq ($(filter distclean maintainer-clean,$(MAKECMDGOALS)),)
clean::
	$(call MAKE_SUBPROJECT,$1) clean
endif
ifeq ($(filter maintainer-clean,$(MAKECMDGOALS)),)
distclean::
	$(call MAKE_SUBPROJECT,$1) distclean
endif
maintainer-clean::
	$(call MAKE_SUBPROJECT,$1) maintainer-clean
endef

ifneq ($(is_root_project),$(true))
$(ROOT_PROJECT_DIR)%:
	$(call MAKE_SUBPROJECT_TARGET, $*)

endif

#endregion subprojects support

#region standard targets support

.DEFAULT_GOAL := all

.PHONY: configure
configure:: $(call _itg_makeutils_print-help,all,Prepare build environment and create intermediate makefiles.)

.PHONY: all
all:: $(call _itg_makeutils_print-help,all,Build all targets.)
all:: configure

.PHONY: check
check: $(call _itg_makeutils_print-help,check,Perform self-tests.)
check: MAKEFLAGS += --keep-going
check: configure

.PHONY: mostlyclean
mostlyclean:: $(call _itg_makeutils_print-help,mostlyclean,Like 'clean'$(COMMA) but may refrain from deleting a few files that people normally don’t want to recompile.)
	$(RMDIR) $(AUXDIR)
	$(RMDIR) $(OUTPUTDIR)

.PHONY: clean
clean:: mostlyclean  $(call _itg_makeutils_print-help,clean,Delete all files in the current directory that are normally created by building the program. Also delete files in other directories if they are created by this makefile. Don’t delete the files that record the configuration.)

.PHONY: distclean
distclean:: clean $(call _itg_makeutils_print-help,distclean,Delete all files in the current directory (or created by this makefile) that are created by configuring or building the program.)
	$(RMDIR) $(CONFIGDIR)

.PHONY: maintainer-clean
maintainer-clean:: distclean $(call _itg_makeutils_print-help,maintainer-clean,This target is intended to be used by a maintainer of the package. Not by ordinary users. You may need special tools to reconstruct some of the files that ‘make maintainer-clean’ deletes. Since these files are normally included in the distribution.)

#endregion standard targets support

endif
