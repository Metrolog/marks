ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GHOSTSCRIPT_DIR

include $(ITG_MAKEUTILS_DIR)pdf.mk

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
    GSFLAGS += -sICCProfilesDir='%rom%iccprofiles/'
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
FILERESOURCEDIR := File/
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

POSTSCRIPTRESOURCEFILES += $(call getPostScriptResourceOutputFiles,$1,$2,$3)

endef

# $(call copyPostScriptResource[, fromDir[, toDir[, files]]] )
define copyPostScriptResource

$(if $3,$(call getPostScriptResourceOutputFiles,$1,$2,$3):) $(if $2,$2,$$(PSRESOURCEOUTPUTDIR))%: $(if $1,$1,$$(PSRESOURCESOURCEDIR))%
	$$(MAKETARGETDIR)
	$$(COPY) $$< $$@
	$$(TOUCH) $$@

POSTSCRIPTRESOURCEFILES += $(call getPostScriptResourceOutputFiles,$1,$2,$3)

endef


GSCMDLINE = $(GS) \
  $(foreach incdir,$(GSINCDIR),-I'$(incdir)') \
  $(if $(GSFONTDIR),-sFONTPATH='$(subst $(__gmsl_space),$(PATHSEP),$(strip $(GSFONTDIR)))')

#  $(if $(PSGENERICRESOURCEDIR),-sGenericResourceDir='$(PSGENERICRESOURCEDIR)') \


GSPSTOPDFFLAGS =

GSPSTOPDFCMDLINE = $(GSCMDLINE) $(GSPSTOPDFFLAGS) \
  -sDEVICE=pdfwrite

$(OUTPUTDIR)%.pdf: $(SOURCESDIR)%.ps $$(POSTSCRIPTRESOURCEFILES)
	$(call writeinformation,Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GSPSTOPDFCMDLINE) -sOutputFile='$@' '$<'
	$(call writeinformation,File "$@" is ready.)
	$(OPENTARGETPDF)


GSPSTOEPSFLAGS =

GSPSTOEPSCMDLINE = $(GSCMDLINE) $(GSPSTOEPSFLAGS) \
  -sDEVICE=eps2write

$(OUTPUTDIR)%.eps: $(SOURCESDIR)%.ps $$(POSTSCRIPTRESOURCEFILES)
	$(call writeinformation,Build file "$@" from "$<"...)
	$(MAKETARGETDIR)
	$(GSPSTOEPSCMDLINE) -sOutputFile='$@' '$<'
	$(call writeinformation,File "$@" is ready.)


ifdef MAKE_TESTS_DIR

# just postscript tests files, without output files

TESTSPSSOURCEDIR ?= $(TESTSDIR)ps/
TESTSPSSOURCEFILES = $(call rwildcard,$(TESTSPSSOURCEDIR),*.ps)

# $(call definePostScriptClearTest,target,source,dependencies)
define definePostScriptClearTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(GSCMDLINE) '$2';,\
  $2 $3 $$(POSTSCRIPTRESOURCEFILES) \
)

endef

# $(call definePostScriptClearTests,dependencies)
definePostScriptClearTests = $(foreach f,$(TESTSPSSOURCEFILES),$(call definePostScriptClearTest,$f,$f,$1))


#  postscript tests files with pdf output

TESTSPS2PDFSOURCEDIR ?= $(TESTSDIR)pdf/
TESTSPS2PDFOUTPUTDIR ?= $(AUXDIR)tests/pdf/
TESTSPS2PDFSOURCEFILES = $(call rwildcard,$(TESTSPS2PDFSOURCEDIR),*.ps)
TESTSPS2PDFOUTPUTFILES = $(patsubst $(TESTSPS2PDFSOURCEDIR)%.ps,$(TESTSPS2PDFOUTPUTDIR)%.pdf,$(TESTSPS2PDFSOURCEFILES))

# $(call definePostScript2PDFTest,target,source,dependencies)
define definePostScript2PDFTest

$(call defineTest,$(basename $(notdir $1)),ps_build,\
  $(MKDIR) $(dir $1);\
  $(GSPSTOPDFCMDLINE) -sOutputFile='$1' '$2';\
  $$(call pushDeploymentArtifactFile,$$(notdir $1),$1);,\
  $2 $3 $$(POSTSCRIPTRESOURCEFILES) \
)

endef

# $(call definePostScript2PDFTests,dependencies)
definePostScript2PDFTests = $(foreach f,$(TESTSPS2PDFSOURCEFILES),$(call definePostScript2PDFTest,$(patsubst $(TESTSPS2PDFSOURCEDIR)%.ps,$(TESTSPS2PDFOUTPUTDIR)%.pdf,$f),$f,$1))


# $(call definePostScriptTests,dependencies)
define definePostScriptTests
$(call definePostScriptClearTests,$1)
$(call definePostScript2PDFTests,$1)
endef

endif

endif
