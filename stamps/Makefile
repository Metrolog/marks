#!/usr/bin/make

all:: marks-pdf marks-eps

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

include $(ITG_MAKEUTILS_DIR)tests/tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor/appveyor.mk

STAMPS_MAKEFILE_LOADED := true

PSRESOURCEOUTPUTDIR = $(AUXDIR)Resource/
PSRESOURCESOURCEDIR = Resource/
STAMPSRCDIR := $(SOURCESDIR)
STAMPSSOURCEFILES := $(call rwildcard,$(STAMPSRCDIR),*.ps)

STAMPLIBDIR := $(PSRESOURCESOURCEDIR)
ENCODINGSDIR := $(STAMPLIBDIR)$(ENCODINGRESOURCEDIR)

ifeq ($(filter %clean .GLOBAL_VARIABLES,$(MAKECMDGOALS)),)
$(eval $(call copyfileto,$(ENCODINGSDIR),$(CP1251TARGET)))
$(eval $(call copyfileto,$(ENCODINGSDIR),$(CP1253TARGET)))
endif

maintainer-clean::
	$(RMDIR) $(ENCODINGSDIR)

GSFONTDIR := $(GSFONTDIR) $(call OSabsPath,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR))

# TODO: перейти на prepare... макросы
$(eval $(foreach f,$(STAMPFONTFILES),$(call copyfileto,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR),$f)))
POSTSCRIPTRESOURCEFILES += $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f))

$(eval $(call preparePostScriptResource,,,$(call uniq,$(call getPostScriptResourceSourceFiles) $(ENCODINGSDIR)$(notdir $(CP1251TARGET)) $(ENCODINGSDIR)$(notdir $(CP1253TARGET)))))
$(eval $(call copyPostScriptResource,$(ITG_POSTSCRIPTLIBDIR),,$(ITG_POSTSCRIPTLIBFILES)))

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(eval $(call definePostScriptTests))

.PHONY: marks-pdf
marks-pdf: $(STAMPSPDFFILES) $(call print-help,marks-pdf,Выполнить подготовку в $(SUBPROJECT_DIR)$(OUTPUTDIR) .pdf файлов с оттисками клейм (только для оттисков полимерных клейм с групповой раскладкой для изготовления полимерных клише) на основе исходных .ps файлов заказов в $(SUBPROJECT_DIR)$(STAMPSRCDIR).)

# TODO: убрать
#.PHONY: pdf
#pdf: $(STAMPSPDFFILES) $(call print-help,pdf,Выполнить подготовку в $(SUBPROJECT_DIR)$(OUTPUTDIR) .pdf файлов с оттисками клейм (только для оттисков полимерных клейм с групповой раскладкой для изготовления полимерных клише) на основе исходных .ps файлов заказов в $(SUBPROJECT_DIR)$(STAMPSRCDIR).)
#	$(pushDeploymentArtifact)


# multiple output files orders support

MULTIFILEORDEROUTPUTDIR = $(OUTPUTDIR)
MULTIFILEORDERAUXDIR = $(AUXDIR)mf/

.PHONY: marks-eps

ifeq (,$(filter guile,$(.FEATURES)))
$(call writeerror,Requires make version that supports Guile feature.)
endif

export GUILE_LOAD_PATH=.
#$(guile (add-to-load-path "."))
$(guile (use-modules (stamps)))

# $(call range, from, to)
range = $(guile (range $1 $2))

# $(call months, numbers)
months = $(foreach m, $1, $(guile (month $m)) )

# $(call quarters, numbers)
quarters = $(foreach q, $1, $(guile (quarter $q)) )

# $(call year)
year = year

# TODO: добавить признак "для первичной поверки / для поверки в эксплуатации" в имя файла или каталог
# $(call get_multifile_order_relative_filename, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, srcfile)
get_multifile_order_relative_filename = $(MULTIFILEORDEROUTPUTDIR)$(patsubst $(SOURCESDIR)%,%,$(basename $7))/$(strip $1)/$(strip $3)/$(strip $2)/$(strip $4)

PSTOOLSDIR =
MARK2IMAGE = $(PSTOOLSDIR)mark2image.ps
MARK2IMAGEARGS ?= -dMirrorPrint -dUseTrimBox

# $(call create_verification_stamp, year, period, stamp_id, stamps_sign, stamp_size, is_for_production, srcfile)
define create_verification_stamp

$(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps: $(MARK2IMAGE) $7 $(MAKEFILE_LIST)
	$$(MAKETARGETDIR)
	iconv -f CP1251 $$< | m4 -D StampId=$(strip $3) | iconv -t CP1251 > $$@

$(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).eps: $(MULTIFILEORDERAUXDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).ps $(POSTSCRIPTRESOURCEFILES) $(MAKEFILE_LIST)
	$$(call writeinformation,Build file "$$@"...)
	$$(MAKETARGETDIR)
	$$(GSPSTOEPSCMDLINE) $$(MARK2IMAGEARGS) -sStampYear=$(strip $1) -sStampPeriod=$(strip $2) -sStampId=$(strip $3) -sStampSign=$(strip $4) -sStampSize='$(strip $5)' -sStampForProduction=$(strip $6) -sOutputFile='$$@' '$$<'

marks-eps: $(MULTIFILEORDEROUTPUTDIR)$(call get_multifile_order_relative_filename,$1,$2,$3,$4,$5,$6,$7).eps

endef

# $(call create_verification_stamps, years, periods, stamp_ids, stamps_signs, stamp_size, is_for_production, srcfile)
define create_verification_stamps
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

MULTIFILEORDERFILES := $(call rwildcard,$(STAMPSRCDIR),*.mk)

$(eval $(foreach f,$(MULTIFILEORDERFILES), $(call include_makefile, $f)))
