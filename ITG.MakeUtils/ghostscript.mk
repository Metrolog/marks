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
  -dNOPLATFONTS \
  -dBATCH

GSINCDIR ?=
GSFONTDIR ?=

ENCODINGRESOURCEDIR := Encoding/
PROCSETRESOURCEDIR := ProcSet/
RESOURCEDIRSUBDIRS = $(ENCODINGRESOURCEDIR) $(PROCSETRESOURCEDIR)

GSCMDLINE = $(GS) \
  -P \
  $(foreach incdir,$(GSINCDIR), -I'$(incdir)') \
  $(if $(GSFONTDIR),-sFONTPATH='$(foreach fontdir,$(GSFONTDIR),$(fontdir)$(PATHSEP))')

GSPSTOPDFCMDLINE = $(GSCMDLINE) \
  -sDEVICE=pdfwrite

$(OUTPUTDIR)%.pdf: $(SOURCESDIR)%.ps
	$(call writeinformation,Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GSPSTOPDFCMDLINE) -sOutputFile='$@' '$<'
	$(call writeinformation,File "$@" is ready.)


# $(call getPostScriptResourceFiles,dirs)
getPostScriptResourceFiles = \
  $(foreach d,$1,$(wildcard $d*.ps) $(foreach s,$(RESOURCEDIRSUBDIRS), $(wildcard $d$s*.ps)))

ifdef MAKE_TESTS_DIR

TESTSPSFILES = $(wildcard $(TESTSDIR)*.ps)
TESTSPDFFILES = $(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(TESTSPSFILES))

# $(call definePostScriptTest,target,source,dependencies)
define definePostScriptTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSCMDLINE) -q '$2';,\
  $2 $3 \
)

endef

# $(call definePostScriptTests,dependencies)
definePostScriptTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptTest,$(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(test)),$(test),$1))

# $(call definePostScriptBuildTest,target,source,dependencies)
define definePostScriptBuildTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSPSTOPDFCMDLINE) -q -sOutputFile='$1' '$2';\
  $$(call pushDeploymentArtifactFile,$$(notdir $1),$1);,\
  $2 $3 \
)

endef

# $(call definePostScriptBuildTests,dependencies)
definePostScriptBuildTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptBuildTest,$(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(test)),$(test),$1))

endif

endif
