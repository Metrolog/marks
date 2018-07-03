ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GHOSTSCRIPT_DIR

MAKE_GHOSTSCRIPT_DIR = $(ITG_MAKEUTILS_DIR)

ifeq ($(OS),Windows_NT)
  ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
    GSTOOL ?= gswin64c
  else
    ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
      GSTOOL ?= gswin64c
    endif
    ifeq ($(PROCESSOR_ARCHITECTURE),x86)
      GSTOOL ?= gswin32c
    endif
  endif
else
  GSTOOL ?= gs
endif

GSFLAGS = \
  -P \
  -dNOPLATFONTS \

# обходное решение для https://github.com/Metrolog/marks/issues/60
ifneq ($(OS),Windows_NT)
  ifeq (9.18,$(lastword $(sort $(shell $(GSTOOL) --version) 9.18)))
    $(call writewarning,Requires ghostscript version 9.19 or higher.)
    GSFLAGS += -sICCProfilesDir=/usr/share/color/icc/ghostscript/
  endif
endif

GS = $(GSTOOL) $(GSFLAGS) \
  -dNOPAUSE \
  -dBATCH

PSRESOURCEOUTPUTDIR ?= $(OUTPUTDIR)Resource/
PSGENERICRESOURCEDIR =
GSINCDIR ?= %rom%Resource/ $(PSRESOURCEOUTPUTDIR)
GSFONTDIR ?=
PSRESOURCESOURCEDIR ?= ./
ENCODINGRESOURCEDIR := Encoding/
PROCSETRESOURCEDIR := ProcSet/
FONTRESOURCEDIR := Font/
RESOURCEDIRSUBDIRS = $(ENCODINGRESOURCEDIR) $(PROCSETRESOURCEDIR)

$(PSRESOURCEOUTPUTDIR) $(PSRESOURCEOUTPUTDIR)$(ENCODINGRESOURCEDIR) $(PSRESOURCEOUTPUTDIR)$(PROCSETRESOURCEDIR):
	$(MAKETARGETASDIR)


# $(call getPostScriptResourceSourceFiles[, resSourceDir])
getPostScriptResourceSourceFiles = \
  $(foreach d,$(if $1,$1,$(PSRESOURCESOURCEDIR)),$(wildcard $d*.ps) $(foreach s,$(RESOURCEDIRSUBDIRS), $(wildcard $d$s*.ps)))

# $(call getPostScriptResourceOutputFiles[, resSourceDir[, resOutputDir[, files]])
getPostScriptResourceOutputFiles = \
  $(patsubst %.ps,%,$(patsubst $(if $1,$1,$(PSRESOURCESOURCEDIR))%,$(if $2,$2,$(PSRESOURCEOUTPUTDIR))%,$(if $3,$3,$(call getPostScriptResourceSourceFiles,$1))))

# $(call preparePostScriptResource[, fromDir[, toDir[, files]]] )
define preparePostScriptResource

$(if $3,$(call getPostScriptResourceOutputFiles,$1,$2,$3):) $(if $2,$2,$$(PSRESOURCEOUTPUTDIR))%: $(if $1,$1,$$(PSRESOURCESOURCEDIR))%.ps
	$$(MAKETARGETDIR)
	$$(COPY) $$< $$@
	$$(TOUCH) $$@

$(if $2,$2,$$(PSRESOURCEOUTPUTDIR)): $(call getPostScriptResourceOutputFiles,$1,$2,$3)

endef

# $(call copyPostScriptResource[, fromDir[, toDir[, files]]] )
define copyPostScriptResource

$(if $3,$(call getPostScriptResourceOutputFiles,$1,$2,$3):) $(if $2,$2,$$(PSRESOURCEOUTPUTDIR))%: $(if $1,$1,$$(PSRESOURCESOURCEDIR))%
	$$(MAKETARGETDIR)
	$$(COPY) $$< $$@
	$$(TOUCH) $$@

$(if $2,$2,$$(PSRESOURCEOUTPUTDIR)): $(call getPostScriptResourceOutputFiles,$1,$2,$3)

endef


GSCMDLINE = $(GS) \
  $(foreach incdir,$(GSINCDIR),-I'$(incdir)') \
  $(if $(GSFONTDIR),-sFONTPATH='$(subst $(SPACE),$(PATHSEP),$(strip $(GSFONTDIR)))')

#  $(if $(PSGENERICRESOURCEDIR),-sGenericResourceDir='$(PSGENERICRESOURCEDIR)') \


GSPSTOPDFFLAGS =

GSPSTOPDFCMDLINE = $(GSCMDLINE) $(GSPSTOPDFFLAGS) \
  -sDEVICE=pdfwrite

$(OUTPUTDIR)%.pdf: $(SOURCESDIR)%.ps
	$(call writeinformation,Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GSPSTOPDFCMDLINE) -sOutputFile='$@' '$<'
	$(call writeinformation,File "$@" is ready.)


ifdef MAKE_TESTS_DIR

TESTSPSFILES = $(wildcard $(TESTSDIR)*.ps)
TESTSPDFFILES = $(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(TESTSPSFILES))

# $(call definePostScriptTest,target,source,dependencies)
define definePostScriptTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSCMDLINE) '$2';,\
  $2 $3 \
)

endef

# $(call definePostScriptTests,dependencies)
definePostScriptTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptTest,$(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(test)),$(test),$1))

# $(call definePostScriptBuildTest,target,source,dependencies)
define definePostScriptBuildTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSPSTOPDFCMDLINE) -sOutputFile='$1' '$2';\
  $$(call pushDeploymentArtifactFile,$$(notdir $1),$1);,\
  $2 $3 \
)

endef

# $(call definePostScriptBuildTests,dependencies)
definePostScriptBuildTests = $(foreach test,$(TESTSPSFILES),$(call definePostScriptBuildTest,$(patsubst $(TESTSDIR)%.ps,$(AUXDIR)%.pdf,$(test)),$(test),$1))

endif

endif
