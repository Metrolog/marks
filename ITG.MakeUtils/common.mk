ifndef MAKE_COMMON_DIR
MAKE_COMMON_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
ITG_MAKEUTILS_LOADED := true

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(patsubst $(abspath $(ROOT_PROJECT_DIR))%,$$(ROOT_PROJECT_DIR)%,$(abspath $(MAKE_COMMON_DIR)))

ifeq (,$(filter oneshell,$(.FEATURES)))
$(error Requires make version that supports .ONESHELL feature.)
endif

ifneq (3.82,$(firstword $(sort $(MAKE_VERSION) 3.82)))
$(error Requires make version 3.82 or higher (that supports .SHELLFLAGS).)
endif

.SECONDARY::;
.SECONDEXPANSION::;
.DELETE_ON_ERROR::;

.DEFAULT_GOAL      := all
.PHONY: all

AUXDIR             ?= obj/
OUTPUTDIR          ?= release/
SOURCESDIR         ?= sources/
CONFIGDIR          ?= config/
# TODO: уйти от абсолютных путей
# TODO: эти переменные вообще вынести в отдельный git.mk
export REPOROOT    ?= $(abspath ./$(ROOT_PROJECT_DIR))/
REPOVERSION        = $(REPOROOT).git/logs/HEAD

SPACE              := $(empty) $(empty)
COMMA              :=,
LEFT_BRACKET       :=(
RIGHT_BRACKET      :=)
DOLLAR_SIGN        :=$$

# $(call dirname,dir)
dirname = $(patsubst %/,%,$1)

# TODO: корректно обернуть abspath и realpath
abspath = $(warning Do not use absolute paths!)$1
realpath = $(warning Do not use absolute paths!)$1

# TODO: уйти cygpath полностью
# TODO: удалить winPath
# $(call winPath,sourcePathOrFileName)
winPath = $(shell cygpath -w $1)

# TODO: удалить shellPath
# $(call shellPath,sourcePathOrFileName)
shellPath = $(shell cygpath -u $1)

ifeq ($(OS),Windows_NT)

PATHSEP            :=;
PowerShell         := powershell
# TODO: удалить OSPath
OSPath             = $(call winPath,$1)

else

PATHSEP            :=:
PowerShell         := /usr/bin/pwsh
# TODO: удалить OSPath
OSPath             = $1

endif

# TODO: уйти от OSPath
OSPath = $(warning Do not use OSPath!)$1

# TODO: удалить OSabsPath
OSabsPath = $(call OSPath,$(abspath $1))

# TODO: удалить OSPath
# под cygwin $(MAKE) == '/usr/bin/make'. Поэтому приходится явно переназначать. Лучше перенести в Windows
#MAKETOOL := $(call OSPath,$(MAKE))
MAKETOOL := make

VERBOSE            ?= true

ifeq ($(VERBOSE),true)
  VERBOSEFLAGS := -Verbose
else
  VERBOSEFLAGS :=
endif

.ONESHELL::

POWERSHELLMODULES  := \
  '$(ITG_MAKEUTILS_DIR)ITG.MakeUtils/ITG.MakeUtils.psd1'

SHELL              := $(PowerShell)

.SHELLFLAGS        = \
  -NoLogo \
  -NonInteractive \
  -ExecutionPolicy unrestricted \
  -Command \
    $$ConfirmPreference = 'High'; \
    $$InformationPreference = 'Continue'; \
    $$ErrorActionPreference = 'Stop'; \
    $$VerbosePreference = 'SilentlyContinue'; \
    $$DebugPreference = 'SilentlyContinue'; \
    $(POWERSHELLMODULES) | Import-Module -ErrorAction 'Stop' -Verbose:$$False;

MKDIR              := mkdir $(VERBOSEFLAGS) -p
MAKETARGETDIR      = $(MKDIR) $(@D)
MAKETARGETASDIR    = $(MKDIR) $@
RMDIR              := rm $(VERBOSEFLAGS) -r -f
RM                 := rm $(VERBOSEFLAGS) -r -f
# TODO: переписать TOUCH на PowerShell
TOUCH              := touch
COPY               := cp $(VERBOSEFLAGS)
CURL               := curl $(VERBOSEFLAGS)
# TODO: переписать ZIP на PowerShell
ZIP                ?= zip -o -9
# TODO: переписать TAR на PowerShell
TAR                ?= tar

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

# $(call setvariable, var, value)
define setvariable
$1:=$2

endef

# $(call copyfile, to, from)
define copyfile
$1: $2
	$$(MAKETARGETDIR)
	$(COPY) $$< $$@
endef

# $(call copyfileto, todir, fromfile)
copyfileto = $(call copyfile,$1/$(notdir $2),$2)

# $(call copyfilefrom, tofile, fromdir)
copyfilefrom = $(call copyfile,$1,$2/$(notdir $1))

# TODO: переписать на PowerShell. Такое соединение через && - только для Windows
# TODO: и выполнить в одну строку
# $(call copyFilesToZIP, targetZIP, sourceFiles, sourceFilesRootDir)
define copyFilesToZIP
$1:$2
	$$(MAKETARGETDIR)
	cd $3 && $(ZIP) -FS -o -r -D $$(abspath $$@) $$(patsubst $3/%, %, $$^)
	$(TOUCH) $$@
endef

$(OUTPUTDIR) $(AUXDIR) $(CONFIGDIR):
	$(MAKETARGETASDIR)

#
# subprojects
#

SUBPROJECTS_EXPORTS_DIR := $(CONFIGDIR)subprojectExports/
$(SUBPROJECTS_EXPORTS_DIR): | $(CONFIGDIR)
	$(MAKETARGETASDIR)

SUBPROJECT_EXPORTS_FILE ?= $(SUBPROJECTS_EXPORTS_DIR)undefined

.PHONY: .GLOBAL_VARIABLES
.GLOBAL_VARIABLES: $(SUBPROJECT_EXPORTS_FILE)
$(SUBPROJECT_EXPORTS_FILE):: $(MAKEFILE_LIST)
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

# $(call calcRootProjectDir, Project)
calcRootProjectAux = $(subst $(SPACE),/,$(patsubst %,..,$(subst /,$(SPACE),$(call getSubProjectDir,$1))))
calcRootProjectDir = $(if $(call calcRootProjectAux,$1),$(call calcRootProjectAux,$1)/,./)

# $(call getSubProjectDir, Project)
getSubProjectDir = $($(1)_DIR)

# $(call setSubProjectDir, Project, ProjectDir)
define setSubProjectDir
export $(1)_DIR := $2/
endef

# $(call MAKE_SUBPROJECT, Project)
MAKE_SUBPROJECT = \
  $(MAKETOOL) \
    -C $(call getSubProjectDir,$1) \
    SUBPROJECT=$1 \
    SUBPROJECT_DIR=$(call getSubProjectDir,$1) \
    ROOT_PROJECT_DIR=$(call calcRootProjectDir,$1) \
    SUBPROJECT_EXPORTS_FILE=$(call calcRootProjectDir,$1)$(SUBPROJECTS_EXPORTS_DIR)$1.mk

# $(call MAKE_SUBPROJECT_TARGET, Target)
MAKE_SUBPROJECT_TARGET = \
  $(MAKETOOL) \
    -C $(ROOT_PROJECT_DIR) \
    ROOT_PROJECT_DIR=$(call calcRootProjectDir,$1) \
    $1

# $(call declareProjectTargets, Project)
define declareProjectTargets
$(call getSubProjectDir,$1)%:
	$(call MAKE_SUBPROJECT,$1) $$*
endef

# $(call useSubProject, SubProject, SubProjectDir [, Targets ])
define useSubProject
$(eval $(call setSubProjectDir,$1,$2))
$(SUBPROJECTS_EXPORTS_DIR)$1.mk: $(call getSubProjectDir,$1)Makefile | $(SUBPROJECTS_EXPORTS_DIR)
	$(call MAKE_SUBPROJECT,$1) .GLOBAL_VARIABLES
.PHONY: $1 $3
ifeq ($(filter %clean,$(MAKECMDGOALS)),)
include $(SUBPROJECTS_EXPORTS_DIR)$1.mk
endif
$1:
	$(call MAKE_SUBPROJECT,$1)
test-$1:
	$(call MAKE_SUBPROJECT,$1) --keep-going test
$3:
	$(call MAKE_SUBPROJECT,$1) $$@
$(foreach target,$3,test-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(foreach target,$3,test.%-$(target)):
	$(call MAKE_SUBPROJECT,$1) --keep-going $$@
$(call getSubProjectDir,$1)%:
	$(call MAKE_SUBPROJECT,$1) $$*
all:: $1
test: test-$1
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

ifdef ROOT_PROJECT_DIR
$(ROOT_PROJECT_DIR)%:
	$(call MAKE_SUBPROJECT_TARGET, $*)

endif

.PHONY: test
test:

.PHONY: check
check: test

.PHONY: mostlyclean
mostlyclean::
	$(RMDIR) $(AUXDIR)
	$(RMDIR) $(OUTPUTDIR)

.PHONY: clean
clean:: mostlyclean

.PHONY: distclean
distclean:: clean
	$(RMDIR) $(CONFIGDIR)

.PHONY: maintainer-clean
maintainer-clean:: distclean

endif
