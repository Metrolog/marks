#!/usr/bin/make

all: pdf

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk

# postscript to PDF build system

STAMPSRCDIR := $(SOURCESDIR)
STAMPSSOURCEFILES := $(wildcard $(STAMPSRCDIR)*.ps)

PSLIBDIR := $(ROOT_PROJECT_DIR)ITG.PostScriptLib/
STAMPLIBDIR := lib/
GSINCDIR := $(GSINCDIR) $(PSLIBDIR) $(STAMPLIBDIR)
ENCODINGSDIR := $(STAMPLIBDIR)Encoding/

$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1251TARGET)))
$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1253TARGET)))

maintainer-clean::
	$(RMDIR) $(ENCODINGSDIR)

STAMPINCFILES := $(wildcard $(PSLIBDIR)*.ps) $(wildcard $(STAMPLIBDIR)*.ps) $(ENCODINGSDIR)CP1251Encoding.ps $(ENCODINGSDIR)CP1253Encoding.ps

STAMPFONTDIR := $(ROOT_PROJECT_DIR)fonts/
GSFONTDIR := $(GSFONTDIR) $(STAMPFONTDIR)
STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)*.pt3)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(STAMPSPDFFILES): $(STAMPINCFILES) $(STAMPFONTFILES)

$(eval $(call definePostScriptBuildTests,$(STAMPINCFILES) $(STAMPFONTFILES)))

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)
