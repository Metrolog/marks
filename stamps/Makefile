#!/usr/bin/make

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

include $(ITG_MAKEUTILS_DIR)tests/tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor/appveyor.mk

__itg_stamps_included:=$(true)

MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILEPREFIX = outputFileFormatSupport
MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILES := $(wildcard $(MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILEPREFIX).*.mk)
MFSUPPORTEDFORMATS := $(foreach f,$(MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILES),$(patsubst $(MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILEPREFIX).%.mk,%,$f))


PSRESOURCEOUTPUTDIR = $(AUXDIR)Resource/
PSRESOURCESOURCEDIR = Resource/
STAMPSRCDIR := $(SOURCESDIR)
STAMPSSOURCEFILES := $(call rwildcard,$(STAMPSRCDIR),*.ps)

STAMPLIBDIR := $(PSRESOURCESOURCEDIR)
ENCODINGSDIR := $(STAMPLIBDIR)$(ENCODINGRESOURCEDIR)

$(eval $(call copy_file_to,$(ENCODINGSDIR),$(CP1251TARGET)))
$(eval $(call copy_file_to,$(ENCODINGSDIR),$(CP1253TARGET)))

maintainer-clean::
	$(RMDIR) $(ENCODINGSDIR)

GSFONTDIR := $(GSFONTDIR) $(call OSabsPath,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR))


define __copy_font_resources_aux
$(foreach f,$(STAMPFONTFILES),$(call copy_file,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(basename $(notdir $f)),$f))
POSTSCRIPTRESOURCEFILES := $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(basename $(notdir $f))) $$(POSTSCRIPTRESOURCEFILES)
endef

$(eval $(call call_as_makefile,$$(call __copy_font_resources_aux),copy_postscript_font_resources.mk))

ifeq ($(call and,$(call not,$(is_productive_target)),$(call not,$(is_clean_target))),$(true))
POSTSCRIPTRESOURCEFILES := $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f)) $$(POSTSCRIPTRESOURCEFILES)
endif

$(eval $(call prepare_PostScript_resource,,,$(call uniq,$(call getPostScriptResourceSourceFiles) $(ENCODINGSDIR)$(notdir $(CP1251TARGET)) $(ENCODINGSDIR)$(notdir $(CP1253TARGET)))))
$(eval $(call copy_PostScript_resource,$(ITG_POSTSCRIPTLIBDIR),,$(ITG_POSTSCRIPTLIBFILES)))

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(eval $(call define_PostScript_tests))

all:: marks-pdf
.PHONY: marks-pdf
marks-pdf: $(STAMPSPDFFILES) $(call print-help,marks-pdf,Выполнить подготовку в $(SUBPROJECT_DIR)$(OUTPUTDIR) .pdf файлов с оттисками клейм (только для оттисков полимерных клейм с групповой раскладкой для изготовления полимерных клише) на основе исходных .ps файлов заказов в $(SUBPROJECT_DIR)$(STAMPSRCDIR).)

# multiple output files orders support

MULTIFILEORDEROUTPUTDIR = $(OUTPUTDIR)mf/
MULTIFILEORDERAUXDIR = $(AUXDIR)mf/
MULTIFILETESTSOUTPUTDIR = $(TESTSOUTPUTDIR)mf/

# $(call range, from, to)
__itg_range_aux = $(shell i=$1; while [[ $$i -le $2 ]]; do printf "%d " $$i; i=$$(( i+1 )); done )
__itg_range_auxII = $(call __itg_range_aux,$(call first,$(call split,_,$1)),$(call last,$(call split,_,$1)))
range = $(call memoize,__itg_range_auxII,$(call merge,_,$1 $2))

# $(call months, numbers)
months = $1

# $(call quarters, numbers)
quarters = $(foreach q,$1,$(call tr,1 2 3 4,I II III IV,$q))

# $(call year)
year = year

# $(call get_multifile_order_relative_filename, srcfile, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, stamp_type)
get_multifile_order_relative_filename = $(patsubst $(SOURCESDIR)%,%,$(basename $1))/$(strip $2)/$(strip $4)/$(strip $3)/$(strip $8)/$(if $(call seq,$(strip $7),true),1,2)/$(strip $5)


define __include_stamps_output_format_support_makefiles_auxII

$(call include_makefile, $(MSSTAMPSOUTPUTFORMATSSUPPORTMAKEFILEPREFIX).$(call lc,$(strip $1)).mk)

ifeq ($$(DONT_USE_$(call uc,$(strip $1))_BY_DEFAULT),$(false))
MFSTAMPSFORMATSDEFAULT := $(strip $1) $$(MFSTAMPSFORMATSDEFAULT)
endif

endef

define __include_stamps_output_format_support_makefiles_aux
$(foreach f,$(MFSUPPORTEDFORMATS),\
  $(call __include_stamps_output_format_support_makefiles_auxII,$f)\
)
endef

$(eval $(call call_as_makefile,$$(call __include_stamps_output_format_support_makefiles_aux),include_stamps_output_format_support_makefiles.mk))

MFSTAMPSFORMATS ?= $(MFSTAMPSFORMATSDEFAULT)

ifeq ($(call set_is_subset,$(call set_create,$(MFSTAMPSFORMATS)),$(call set_create,$(MFSUPPORTEDFORMATS))),$(false))
$(call writeerror,MFSTAMPSFORMATS contains unsupported file types. Must contains any from: $(MFSUPPORTEDFORMATS))
endif

all:: marks-pdf

# $(call define_stamps_output_file_rule, file_type_slug)
define __define_stamps_output_file_rule_aux

$(OUTPUTDIR)%.$(call lc,$(strip $1)): $(SOURCESDIR)%.ps $$(POSTSCRIPTRESOURCEFILES) | $$(TARGETDIR)
	$$(PSTO$(call uc,$(strip $1))CMDLINE) -sOutputFile='$$@' '$$<'

$(TESTSOUTPUTDIR)%.$(call lc,$(strip $1)): $(SOURCESDIR)%.ps $$(POSTSCRIPTRESOURCEFILES) | $$(TARGETDIR)
	$$(PSTO$(call uc,$(strip $1))CMDLINE) -sOutputFile='$$@' '$$<'

endef

define_stamps_output_file_rule=$(call call_as_makefile,\
  $$(call __define_stamps_output_file_rule_aux,$1),\
  $(call merge,_,define_stamps_output_file_rule $(call strip,$1)).mk\
)

$(eval $(foreach f,$(MFSUPPORTEDFORMATS),$(call define_stamps_output_file_rule,$f)))


# $(call define_multifile_stamps_images_rule, file_type)
define __define_multifile_stamps_images_rule_aux

$(MULTIFILEORDEROUTPUTDIR)%.$(call lc,$(strip $1)): $(MULTIFILEORDERAUXDIR)%.ps $$(POSTSCRIPTRESOURCEFILES) $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	$$(PSTO$(call uc,$(strip $1))CMDLINE) -sOutputFile='$$@' '$$<'

$(MULTIFILETESTSOUTPUTDIR)%.$(call lc,$(strip $1)): $(MULTIFILEORDERAUXDIR)%.ps $$(POSTSCRIPTRESOURCEFILES) $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	$$(PSTO$(call uc,$(strip $1))CMDLINE) -sOutputFile='$$@' '$$<'

endef

define_multifile_stamps_images_rule=$(call call_as_makefile,\
  $$(call __define_multifile_stamps_images_rule_aux,$1),\
  $(call merge,_,define_multifile_stamps_images_rule $(call strip,$1)).mk\
)

$(eval $(foreach f,$(MFSUPPORTEDFORMATS),$(call define_multifile_stamps_images_rule,$f)))


PSTOOLSDIR =
MARK2IMAGE = $(PSTOOLSDIR)mark2image.ps

__multifile_stamps_ps_recipe_aux = \
  set -o pipefail; \
  export LANG=ru_RU.UTF8; \
  iconv -f CP1251 $2 \
  | m4 \
    -D StampYear=\($(strip $(StampYear))\) \
    -D StampPeriod=\($(if $(call seq,$(strip $(StampPeriod)),year),,$(strip $(StampPeriod)))\) \
    -D StampId=\($(strip $(StampId))\) \
    -D StampSign=$(strip $(StampSign)) \
    -D StampSize='$(strip $(StampSize))' \
    -D StampForProduction=$(strip $(StampForProduction)) \
    -D StampFunctor=$(strip $(StampFunctor)) \
    -D StampDPI=$(STAMPS_DPI) \
  | iconv -t CP1251 > $1

$(MULTIFILEORDERAUXDIR)%.ps: $(MARK2IMAGE) $(call __itg_get_static_makefile_list) | $(TARGETDIR)
	$(call __multifile_stamps_ps_recipe_aux,$@,$<)

# $(call create_stamp, srcfile, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, stamp_type)

get_multifile_order_slug = $(call lc,$(call merge,_,$(call split,/,$(patsubst $(SOURCESDIR)%.mk,%,$1))))

define __create_stamp_aux

marks-$(strip $1)-$(strip $2): $3

endef

define create_stamp

$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: $(strip $1)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampYear:=$(strip $2)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampPeriod:=$(strip $3)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampId:=$(strip $4)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampSign:=$(strip $5)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampSize:=$(strip $6)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampForProduction:=$(strip $7)
$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).ps: StampFunctor:=$(strip $(if $(call __gmsl_make_bool,$8),/$(strip $8)_upath,/verification_stamp_upath))

$(foreach f,$(MFSUPPORTEDFORMATS),\
  $(call __create_stamp_aux,\
    $(call get_multifile_order_slug,$1),\
    $f,\
    $(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7,$8).$(call lc,$(strip $f))\
  )\
)
endef

MULTIFILEAUXMAKEFILESDIR = $(AUXDIR)mf/

get_multifile_order_intermediate_makefile_name = $(call merge,_,build_multifile_order $(call get_multifile_order_slug,$1)).mk

define __multifile_order_intermediate_makefile_aux
# source file: $1

$(foreach STAMPS_PERIOD,$(STAMPS_PERIODS), \
  $(foreach STAMPS_SIGN,$(STAMPS_SIGNS), \
    $(call create_stamp,\
      $1,\
      $(STAMPS_YEAR),\
      $(STAMPS_PERIOD),\
      $(STAMPS_ID),\
      $(STAMPS_SIGN),\
      $(STAMPS_SIZE),\
      $(if $(call seq,$(STAMPS_VARIANT),1),true,false),\
      $(STAMPS_TYPE)\
    ) \
  ) \
)
endef

define __foreach_multifile_order_auxII

marks-$(strip $1): marks-$(strip $1)-$(strip $2)
.PHONY: marks-$(strip $1)-$(strip $2)
endef

define __foreach_multifile_order_aux
# source file: $1

STAMPS_DPI     := 2400

STAMPS_SIGNS   := 0
STAMPS_SIZE    := 18 mm
STAMPS_VARIANT := 1
STAMPS_TYPE    := verification_stamp
$(eval $(call include_makefile, $1))

all:: marks-$(strip $(call get_multifile_order_slug,$1))

.PHONY: marks-$(strip $(call get_multifile_order_slug,$1))

$(foreach f,$(MFSTAMPSFORMATS),\
  $(call __foreach_multifile_order_auxII,\
    $(call get_multifile_order_slug,$1),\
    $f\
  )\
)

$(foreach v,DPI YEAR ID PERIODS SIGNS SIZE VARIANT TYPE,\
  $(__gmsl_newline)$(MULTIFILEAUXMAKEFILESDIR)$(call get_multifile_order_intermediate_makefile_name,$1): STAMPS_$v:=$(strip $(STAMPS_$v))\
)
$(call call_as_build_makefile,$$(call __multifile_order_intermediate_makefile_aux,$1),\
  $(call get_multifile_order_intermediate_makefile_name,$1),\
  $(MULTIFILEAUXMAKEFILESDIR),\
  $1\
)
endef

MULTIFILEORDERFILES := $(call rwildcard,$(STAMPSRCDIR),*.mk)

$(eval $(foreach f,$(MULTIFILEORDERFILES),\
  $(call call_as_build_makefile,$$(call __foreach_multifile_order_aux,$f),\
    $(call merge,_,prepare_multifile_order $(call get_multifile_order_slug,$f)).mk\
  )\
))


#MULTIFILETARGETSUFFIX = -tests
MULTIFILETESTSSOURCEDIR ?= $(TESTSDIR)mf/
#MULTIFILEORDERCURRENTOUTPUTDIR = $(MULTIFILETESTSOUTPUTDIR)
MULTIFILETESTSFILES := $(call rwildcard,$(MULTIFILETESTSSOURCEDIR),*.mk)

#$(eval $(foreach f,$(MULTIFILETESTSFILES), $(call include_check_makefile, $f)))
