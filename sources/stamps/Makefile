###
### GNU make Makefile
###

all: pdf

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

# tools

ifeq ($(VIEWPDF),yes)
	VIEWPDFOPT := -pv -e '$$pdf_previewer=q/$(PDFVIEWER) %O %S/'
else
	VIEWPDFOPT := -pv-
endif

ifeq ($(OS),Windows_NT)

GS                 ?= gswin64c \
	-dSAFER \
	-dNOPAUSE \
	-dBATCH \
	-sDEVICE=pdfwrite \
	-dNOPLATFONTS

PDFVIEWER          ?= start

else

GS                 ?= gs
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

STAMPFONTDIR := ../../fonts
STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)/*.pfb)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)/%.pdf,$(STAMPSSOURCEFILES))

$(OUTPUTDIR)/%.pdf: $(STAMPSRCDIR)%.ps $(STAMPFONTFILES)
	$(info Build file "$@"...)
	$(MAKETARGETDIR)
	$(GS) \
    -sOutputFile=$@ \
    -sFONTPATH=$(call OSabsPath,$(STAMPFONTDIR)) \
    $<

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
