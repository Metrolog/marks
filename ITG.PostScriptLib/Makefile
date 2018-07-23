#!/usr/bin/make

all:

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk

$(eval $(call preparePostScriptResource))

GSINCDIR := $(GSINCDIR) $(PSRESOURCEOUTPUTDIR)

PSLIBSRCFILES := $(call getPostScriptResourceSourceFiles)
ITG_POSTSCRIPTLIBFILES := $(POSTSCRIPTRESOURCEFILES)
ITG_POSTSCRIPTLIBDIR := $(PSRESOURCEOUTPUTDIR)

.PHONY: ITG_PostScriptLib
all: ITG_PostScriptLib

ITG_PostScriptLib: $(ITG_POSTSCRIPTLIBFILES)
$(eval $(call pushArtifactTargets,ITG_POSTSCRIPTLIBFILES))
$(eval $(call pushArtifactTargets,ITG_POSTSCRIPTLIBDIR))

$(eval $(call definePostScriptTests))
