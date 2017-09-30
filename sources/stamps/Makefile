###
### GNU make Makefile
###

all: pdf

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

# tools

ifeq ($(OS),Windows_NT)

GS                 ?= gswin64c \
	-dSAFER \
	-dNOPAUSE \
	-dBATCH \
	-sDEVICE=pdfwrite \
	-dNOPLATFONTS

PDFVIEWER          ?= start

else

GS                 ?= gs \
	-dSAFER \
	-dNOPAUSE \
	-dBATCH \
	-sDEVICE=pdfwrite \
	-dNOPLATFONTS

PDFVIEWER          ?= start

endif

# postscript to PDF build system

STAMPSRCDIR := 
STAMPSSOURCEFILES := $(wildcard $(STAMPSRCDIR)*.ps)

STAMPINCDIR := ../inc

$(eval $(call copyfile, $(STAMPINCDIR)/cp1251.ps, $(CP1251TARGET)))
$(eval $(call copyfile, $(STAMPINCDIR)/cp1253.ps, $(CP1253TARGET)))

STAMPINCFILES := $(wildcard $(STAMPINCDIR)/*.ps) $(STAMPINCDIR)/cp1251.ps $(STAMPINCDIR)/cp1253.ps

STAMPFONTDIR := ../../fonts
STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)/*.pt3)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)/%.pdf,$(STAMPSSOURCEFILES))

$(OUTPUTDIR)/%.pdf: $(STAMPSRCDIR)%.ps $(STAMPINCFILES) $(STAMPFONTFILES)
	$(info Build file "$@"...)
	$(MAKETARGETDIR)
	$(GS) \
    -sOutputFile=$@ \
    -I$(call OSabsPath,$(STAMPINCDIR)) \
    -sFONTPATH=$(call OSabsPath,$(STAMPFONTDIR)) \
    $<

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)
