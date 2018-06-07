ifndef MAKE_GHOSTSCRIPT_DIR
MAKE_GHOSTSCRIPT_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_GHOSTSCRIPT_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

ifeq ($(OS),Windows_NT)

GSTOOL ?= gswin64c

else

GSTOOL ?= gs

endif

GS = $(GSTOOL) \
  -dSAFER \
  -dNOPAUSE \
  -dBATCH \
  -sDEVICE=pdfwrite \
  -dNOPLATFONTS

GSINCDIR ?=
GSFONTDIR ?=

$(OUTPUTDIR)/%.pdf: $(SOURCESDIR)/%.ps
	$(info Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GS) -sOutputFile='$(call OSPath,$@)' $(foreach incdir,$(GSINCDIR),-I'$(call OSabsPath,$(incdir))') -sFONTPATH='$(call OSabsPath,$(GSFONTDIR))' '$(call OSPath,$<)'

endif