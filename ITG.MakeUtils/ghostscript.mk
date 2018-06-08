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


ifdef MAKE_TESTS_DIR

TESTSPSFILES = $(wildcard $(TESTSDIR)/*.ps)
TESTSPDFFILES = $(patsubst $(TESTSDIR)/%.ps,$(AUXDIR)/%.pdf,$(TESTSPSFILES))

# $(call definePSBuildTest,target,source,dependencies)
define definePSBuildTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $$(GS) -q -sOutputFile='$$(call OSPath,$1)' $$(foreach incdir,$$(GSINCDIR),-I'$$(call OSabsPath,$$(incdir))') -sFONTPATH='$$(call OSabsPath,$(GSFONTDIR))' '$$(call OSPath,$2)';,\
  $2 $3 \
)

endef

# $(call definePSBuildTests,dependencies)
definePSBuildTests = $(foreach test,$(TESTSPSFILES),$(call definePSBuildTest,$(patsubst $(TESTSDIR)/%.ps,$(AUXDIR)/%.pdf,$(test)),$(test),$1))

endif

endif