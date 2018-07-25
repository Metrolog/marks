#!/usr/bin/make

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)tests/tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor/appveyor.mk

$(eval $(call preparePostScriptResource))

GSINCDIR := $(GSINCDIR) $(PSRESOURCEOUTPUTDIR)

PSLIBSRCFILES := $(call getPostScriptResourceSourceFiles)
ITG_POSTSCRIPTLIBFILES := $(POSTSCRIPTRESOURCEFILES)
ITG_POSTSCRIPTLIBDIR := $(PSRESOURCEOUTPUTDIR)

.PHONY: ITG_PostScriptLib
all:: ITG_PostScriptLib

ITG_PostScriptLib: $(ITG_POSTSCRIPTLIBFILES) $(call print-help,ITG_PostScriptLib,Prepare postscript Resource dir in $(PSRESOURCEOUTPUTDIR) with ProcSet and other resources from ITG.PostScriptLib.)
$(eval $(call pushArtifactTargets,ITG_POSTSCRIPTLIBFILES))
$(eval $(call pushArtifactTargets,ITG_POSTSCRIPTLIBDIR))

$(eval $(call definePostScriptTests))
