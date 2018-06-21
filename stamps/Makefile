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

$(eval $(call copyfile, $(STAMPLIBDIR)cp1251.ps, $(CP1251TARGET)))
$(eval $(call copyfile, $(STAMPLIBDIR)cp1253.ps, $(CP1253TARGET)))

maintainer-clean::
	$(RM) $(STAMPLIBDIR)cp1251.ps
	$(RM) $(STAMPLIBDIR)cp1253.ps

STAMPINCFILES := $(wildcard $(PSLIBDIR)*.ps) $(wildcard $(STAMPLIBDIR)*.ps) $(STAMPLIBDIR)cp1251.ps $(STAMPLIBDIR)cp1253.ps

STAMPFONTDIR := $(ROOT_PROJECT_DIR)fonts/
GSFONTDIR := $(GSFONTDIR) $(STAMPFONTDIR)
STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)*.pt3)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

$(STAMPSPDFFILES): $(STAMPINCFILES) $(STAMPFONTFILES)

$(eval $(call definePostScriptBuildTests,$(STAMPINCFILES) $(STAMPFONTFILES)))

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)
