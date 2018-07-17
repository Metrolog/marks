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

$(info ----$(foreach x, $(guile (do ((i 1 (1+ i))) ((> i 4)) (list i) )), aa$xbb )----)

$(guile (for/and ([l '(1 2 3 "error?")]) (< l 3)))


#$(guile (for ([a '(a b c)]) (display a)))

#$(info ----$(foreach x, $(guile (for ([a (in-range 1 15)]) a) ), aa$xbb )----)


# $(call range, from, to)
define range
endef

# $(call range, numbers)
months = [ $1 ] months

# $(call range, numbers)
quarters = [ $1 ] quarters

# $(call range)
year = year

# $(call create_verification_stamp, years, periods, stamp_ids, stamps_signs, stamp_size, is_for_production)
define create_verification_stamp
      2017
      % [ [ 1 2  3 6 range  10 ] months  [ 1 4 range ] quarters ]
      [ [ 3 ] quarters ]     % периоды
      (СП)                   % шифр поверительного клейма
      [ 1 256 range ]        % диапазон знаков поверителей
      18.0 mm                % размер клейма
      false                  % поверка в эксплуатации или после ремонта
      /verification_stamp_upath
endef

MULTIFILEORDERFILES := $(call rwildcard,$(STAMPSRCDIR),*.mk)

$(eval $(foreach f,$(MULTIFILEORDERFILES), $(call includemakefile, $f)))
