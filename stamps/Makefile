#!/usr/bin/make

all: pdf

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk


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



$(info =========================)
$(info Guile tests:)

NAMES := liesl friedrich louisa kurt brigitta marta gretl
$(info $(guile (reverse '($(NAMES)))))

define setup
(use-modules (srfi srfi-1))
(define (range from to) (map (lambda (x) (+ from x)) (iota (- to from))))
endef
$(guile $(setup))

#$(info $(guile (for/list ([i (in-range 10 20)]) i) ))

$(info $(guile (range 10 20) ))

