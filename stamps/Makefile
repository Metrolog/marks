###
### GNU make Makefile
###

all: pdf

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

# postscript to PDF build system

STAMPSRCDIR := $(SOURCESDIR)/
STAMPSSOURCEFILES := $(wildcard $(STAMPSRCDIR)*.ps)

STAMPINCDIR := ../ITG.PostScriptLib
GSINCDIR := $(GSINCDIR) $(STAMPINCDIR)

$(eval $(call copyfile, $(STAMPINCDIR)/cp1251.ps, $(CP1251TARGET)))
$(eval $(call copyfile, $(STAMPINCDIR)/cp1253.ps, $(CP1253TARGET)))

STAMPINCFILES := $(wildcard $(STAMPINCDIR)/*.ps) $(STAMPINCDIR)/cp1251.ps $(STAMPINCDIR)/cp1253.ps

STAMPFONTDIR := ../fonts
GSFONTDIR := $(GSFONTDIR) $(STAMPFONTDIR)
STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)/*.pt3)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)/%.pdf,$(STAMPSSOURCEFILES))

$(STAMPSPDFFILES): $(STAMPINCFILES) $(STAMPFONTFILES)

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)
