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

GS                 ?= gswin32c
PDFVIEWER          ?= start

else

GS                 ?= gs
PDFVIEWER          ?= start

endif

# postscript to PDF build system

STAMPSRCDIR := .
STAMPSSOURCEFILES := $(wildcard $(STAMPSRCDIR)/*.ps)

STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)/%,$(OUTPUTDIR)/%,$(STAMPSSOURCEFILES))

$(STAMPSPDFFILES): $(STAMPSSOURCEFILES)
	$(info Build file "$@"...)
	$(MAKETARGETDIR)

#	cd $(<D) && $(LATEXUNPACK) $(<F)

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
