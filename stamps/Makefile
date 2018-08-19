#!/usr/bin/make

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

include $(ITG_MAKEUTILS_DIR)tests/tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor/appveyor.mk

__itg_stamps_included:=$(true)

MFSUPPORTEDFORMATS = pdf pcx tiff eps
MFSTAMPSFORMATS ?= pdf pcx tiff # eps

ifeq ($(call set_is_subset,$(call set_create,$(MFSTAMPSFORMATS)),$(call set_create,$(MFSUPPORTEDFORMATS))),$(false))
$(call writeerror,MFSTAMPSFORMATS contains unsupported file types. Must contains any from: $(MFSUPPORTEDFORMATS))
endif

all:: $(foreach f,$(MFSTAMPSFORMATS),marks-$(strip $f))

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

ifeq ($(call and,$(call not,$(is_productive_target)),$(call not,$(is_clean))),$(true))
POSTSCRIPTRESOURCEFILES := $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f)) $$(POSTSCRIPTRESOURCEFILES)
endif


$(eval $(call prepare_PostScript_resource,,,$(call uniq,$(call getPostScriptResourceSourceFiles) $(ENCODINGSDIR)$(notdir $(CP1251TARGET)) $(ENCODINGSDIR)$(notdir $(CP1253TARGET)))))
$(eval $(call copy_PostScript_resource,$(ITG_POSTSCRIPTLIBDIR),,$(ITG_POSTSCRIPTLIBFILES)))

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(eval $(call define_PostScript_tests))

.PHONY: marks-pdf
marks-pdf: $(STAMPSPDFFILES) $(call print-help,marks-pdf,Выполнить подготовку в $(SUBPROJECT_DIR)$(OUTPUTDIR) .pdf файлов с оттисками клейм (только для оттисков полимерных клейм с групповой раскладкой для изготовления полимерных клише) на основе исходных .ps файлов заказов в $(SUBPROJECT_DIR)$(STAMPSRCDIR).)

# multiple output files orders support

MULTIFILEORDEROUTPUTDIR = $(OUTPUTDIR)
MULTIFILEORDERAUXDIR = $(AUXDIR)mf/

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

# $(call get_multifile_order_relative_filename, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, srcfile)
get_multifile_order_relative_filename = $(MULTIFILEORDEROUTPUTDIR)$(patsubst $(SOURCESDIR)%,%,$(basename $7))/$(strip $1)/$(strip $3)/$(strip $2)/$(strip $4).$(if $(call seq,$(strip $6),true),1,2)


GSPSTOPCXFLAGS =
GSPSTOPCXCMDLINE = $(GSCMDLINE) $(GSPSTOPCXFLAGS) \
  -sDEVICE=pcxmono

GSPSTOTIFFFLAGS =
GSPSTOTIFFCMDLINE = $(GSCMDLINE) $(GSPSTOTIFFFLAGS) \
  -sDEVICE=tiffpack


# $(call define_multifile_stamps_images_rule, file_type)
define __define_multifile_stamps_images_rule_aux

$(OUTPUTDIR)%.$(strip $1): $(SOURCESDIR)%.ps $$(POSTSCRIPTRESOURCEFILES) | $(TARGETDIR)
	$(GSPSTO$(call uc,$(strip $1))CMDLINE) -sOutputFile='$$@' '$$<'

endef

define_multifile_stamps_images_rule=$(call call_as_makefile,$$(call __define_multifile_stamps_images_rule_aux,$1),$(call merge,_,define_multifile_stamps_images_rule $(call strip,$1)).mk)

$(eval $(foreach f,$(MFSUPPORTEDFORMATS),$(call define_multifile_stamps_images_rule,$f)))


PSTOOLSDIR =
MARK2IMAGE = $(PSTOOLSDIR)mark2image.ps
MARK2IMAGEARGS ?= -q -dMirrorPrint -dUseTrimBox

.PHONY: marks-eps
.PHONY: marks-pcx
.PHONY: marks-tiff

# $(call create_verification_stamp, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, srcfile)
define create_verification_stamp

$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps: $(MARK2IMAGE) $7 $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	set -o pipefail; \
  export LANG=ru_RU.UTF8; \
  iconv -f CP1251 $$< \
  | m4 \
    -D StampYear=\($(strip $1)\) \
    -D StampPeriod=\($(if $(call seq,$(strip $2),year),,$(strip $2))\) \
    -D StampId=\($(strip $3)\) \
    -D StampSign=$(strip $4) \
    -D StampSize='$(strip $5)' \
    -D StampForProduction=$(strip $6) \
  | iconv -t CP1251 > $$@

$(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).eps: $(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps $$(POSTSCRIPTRESOURCEFILES) $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	$$(GSPSTOEPSCMDLINE) $$(MARK2IMAGEARGS) -sOutputFile='$$@' '$$<'

marks-eps: $(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).eps

$(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).pcx: $(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps $$(POSTSCRIPTRESOURCEFILES) $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	$$(GSPSTOPCXCMDLINE) $$(MARK2IMAGEARGS) -sOutputFile='$$@' '$$<'

marks-pcx: $(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).pcx

$(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).tif: $(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps $$(POSTSCRIPTRESOURCEFILES) $(call __itg_get_static_makefile_list) | $$(TARGETDIR)
	$$(GSPSTOTIFFCMDLINE) $$(MARK2IMAGEARGS) -sOutputFile='$$@' '$$<'

marks-tiff: $(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).tif

endef

# $(call create_verification_stamps, years, periods, stamp_ids, stamps_signs, stamp_size, is_for_production, srcfile)
define __create_verification_stamps_aux
	$(foreach year,$1, \
		$(foreach period,$2, \
			$(foreach id,$3, \
				$(foreach sign,$4, \
					$(foreach is_for_production,$6, \
						$(call create_verification_stamp, $(year), $(period), $(id), $(sign), $5, $(is_for_production), $7) \
					) \
				) \
			) \
		) \
	)
endef

create_verification_stamps=$(call call_as_makefile,$$(call __create_verification_stamps_aux,$1,$2,$3,$4,$5,$6,$7),$(call merge,_,create_verification_stamps $(call split,/,$(basename $7))).mk)

MULTIFILEORDERFILES := $(call rwildcard,$(STAMPSRCDIR),*.mk)

$(eval $(foreach f,$(MULTIFILEORDERFILES), $(call include_makefile, $f)))
