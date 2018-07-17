#!/usr/bin/make

all: pdf

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk

STAMPS_MAKEFILE_LOADED := true

PSRESOURCEOUTPUTDIR = $(AUXDIR)Resource/
PSRESOURCESOURCEDIR = Resource/
STAMPSRCDIR := $(SOURCESDIR)
STAMPSSOURCEFILES := $(call rwildcard,$(STAMPSRCDIR),*.ps)

STAMPLIBDIR := $(PSRESOURCESOURCEDIR)
ENCODINGSDIR := $(STAMPLIBDIR)$(ENCODINGRESOURCEDIR)

ifeq ($(filter %clean,$(MAKECMDGOALS)),)
$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1251TARGET)))
$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1253TARGET)))
endif

maintainer-clean::
	$(RMDIR) $(ENCODINGSDIR)

GSFONTDIR := $(GSFONTDIR) $(call OSabsPath,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR))

# TODO: перейти на prepare... макросы
$(eval $(foreach f,$(STAMPFONTFILES),$(call copyfileto,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR),$f)))
POSTSCRIPTRESOURCEFILES += $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f))

$(eval $(call preparePostScriptResource))
$(eval $(call copyPostScriptResource,$(ITG_POSTSCRIPTLIBDIR),,$(ITG_POSTSCRIPTLIBFILES)))

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(eval $(call definePostScriptTests))

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)


# multiple output files orders support

ifeq (,$(filter guile,$(.FEATURES)))
$(call writeerror,Requires make version that supports Guile feature.)
endif

$(guile (add-to-load-path "."))
$(guile (use-modules (stamps)))

# $(call range, from, to)
range = $(guile (range $1 $2))

# $(call months, numbers)
months = $(foreach m, $1, $(guile (month $m)) )

# $(call quarters, numbers)
quarters = $(foreach q, $1, $(guile (quarter $q)) )

# $(call year)
year = year

# $(call create_verification_stamp, year, period, stamp_id, stamps_sign, stamp_size, is_for_production)
define create_verification_stamp
	$(info Y $1 P $2 I $3 S $4 Z $5 P $6)
endef

# $(call create_verification_stamps, years, periods, stamp_ids, stamps_signs, stamp_size, is_for_production)
define create_verification_stamps
	$(foreach year,$1, \
		$(foreach period,$2, \
			$(foreach id,$3, \
				$(foreach sign,$4, \
					$(foreach is_for_production,$6, \
						$(call create_verification_stamp, $(year), $(period), $(id), $(sign), $5, $(is_for_production)) \
					) \
				) \
			) \
		) \
	)
endef

MULTIFILEORDERFILES := $(call rwildcard,$(STAMPSRCDIR),*.mk)

$(eval $(foreach f,$(MULTIFILEORDERFILES), $(call includemakefile, $f)))
