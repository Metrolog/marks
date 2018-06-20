ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GHOSTSCRIPT_DIR

MAKE_GHOSTSCRIPT_DIR = $(ITG_MAKEUTILS_DIR)

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

GSCMDLINE = $(GS) \
  $(foreach incdir,$(GSINCDIR), -I'$(call OSabsPath,$(incdir))') \
  $(if $(GSFONTDIR),-sFONTPATH='$(foreach fontdir,$(GSFONTDIR),$(call OSabsPath,$(fontdir))$(PATHSEP))')

$(OUTPUTDIR)/%.pdf: $(SOURCESDIR)/%.ps
	$(call writeinformation,Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GSCMDLINE) -sOutputFile='$(call OSPath,$@)' '$(call OSPath,$<)'
	$(call writeinformation,File "$@" is ready.)


ifdef MAKE_TESTS_DIR

TESTSPSFILES = $(wildcard $(TESTSDIR)/*.ps)
TESTSPDFFILES = $(patsubst $(TESTSDIR)/%.ps,$(AUXDIR)/%.pdf,$(TESTSPSFILES))

# $(call definePostScriptTest,target,source,dependencies)
define definePostScriptTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSCMDLINE) -q -sOutputFile='$$(call OSPath,$1)' '$$(call OSPath,$2)';,\
  $2 $3 \
)

endef

# $(call definePostScriptTests,dependencies)
definePostScriptTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptTest,$(patsubst $(TESTSDIR)/%.ps,$(AUXDIR)/%.pdf,$(test)),$(test),$1))

# $(call definePostScriptBuildTest,target,source,dependencies)
define definePostScriptBuildTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSCMDLINE) -q -sOutputFile='$$(call OSPath,$1)' '$$(call OSPath,$2)';\
  $$(call pushDeploymentArtifactFile,$$(notdir $1),$$(call OSPath,$1));,\
  $2 $3 \
)

endef

# $(call definePostScriptBuildTests,dependencies)
definePostScriptBuildTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptBuildTest,$(patsubst $(TESTSDIR)/%.ps,$(AUXDIR)/%.pdf,$(test)),$(test),$1))

endif

endif
