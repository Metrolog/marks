#!/usr/bin/make

all: pdf

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk


PSRESOURCEOUTPUTDIR = $(AUXDIR)Resource/
PSRESOURCESOURCEDIR = Resource/
STAMPSRCDIR := $(SOURCESDIR)
STAMPSSOURCEFILES := $(wildcard $(STAMPSRCDIR)*.ps)

STAMPLIBDIR := $(PSRESOURCESOURCEDIR)
ENCODINGSDIR := $(STAMPLIBDIR)$(ENCODINGRESOURCEDIR)

ifeq ($(filter %clean,$(MAKECMDGOALS)),)
$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1251TARGET)))
$(eval $(call copyfileto, $(ENCODINGSDIR), $(CP1253TARGET)))
endif

maintainer-clean::
	$(RMDIR) $(ENCODINGSDIR)

# TODO: заменить на файлы в $(PSRESOURCEOUTPUTDIR)
STAMPINCFILES := \
  $(ITG_POSTSCRIPTLIBFILES) \
  $(call getPostScriptResourceFiles,$(STAMPLIBDIR)) \
  $(ENCODINGSDIR)CP1251Encoding.ps \
  $(ENCODINGSDIR)CP1253Encoding.ps

#STAMPFONTDIR := $(ROOT_PROJECT_DIR)fonts/
# TODO: убрать вообще после отладки
GSFONTDIR := $(GSFONTDIR) $(shell cygpath -w $(abspath $(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)))
# TODO: заменить на файлы в $(PSRESOURCEOUTPUTDIR)
#STAMPFONTFILES := $(wildcard $(STAMPFONTDIR)*.pt3)

# TODO: скопировать шрифты нужно
$(PSRESOURCEOUTPUTDIR): $(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)

$(eval $(foreach f,$(STAMPFONTFILES),$(call copyfileto,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR),$f)))
$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR): $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f))

# TODO: скопировать локальную библиотеку нужно
$(eval $(call copyPostScriptResource))
$(PSRESOURCEOUTPUTDIR): $(call getPostScriptResourceOutputFiles)

# TODO: скопировать основную библиотеку нужно
#$(eval $(call copyPostScriptResource,$(ITG_POSTSCRIPTLIBFILES),$(ITG_POSTSCRIPTLIBDIR)))
$(eval $(foreach f,$(ITG_POSTSCRIPTLIBFILES),$(call copyfile,$(patsubst $(ITG_POSTSCRIPTLIBDIR)%,$(PSRESOURCEOUTPUTDIR)%,$f),$f)))
$(PSRESOURCEOUTPUTDIR): $(patsubst $(ITG_POSTSCRIPTLIBDIR)%,$(PSRESOURCEOUTPUTDIR)%,$(ITG_POSTSCRIPTLIBFILES))

#$(PSRESOURCEOUTPUTDIR): $(PSRESOURCEOUTPUTDIR)$(ENCODINGRESOURCEDIR)
#$(eval $(foreach f,$(STAMPFONTFILES),$(call copyfileto,$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR),$f)))
#$(PSRESOURCEOUTPUTDIR)$(ENCODINGRESOURCEDIR): $(foreach f,$(STAMPFONTFILES),$(PSRESOURCEOUTPUTDIR)$(FONTRESOURCEDIR)$(notdir $f))



STAMPSPDFFILES := $(patsubst $(STAMPSRCDIR)%.ps,$(OUTPUTDIR)%.pdf,$(STAMPSSOURCEFILES))

# TODO: проверить зависимости
$(STAMPSPDFFILES): $(PSRESOURCEOUTPUTDIR)
#$(STAMPSPDFFILES): $(STAMPINCFILES) $(STAMPFONTFILES)

# TODO: проверить зависимости
#$(eval $(call definePostScriptBuildTests,$(STAMPINCFILES) $(STAMPFONTFILES)))
$(eval $(call definePostScriptBuildTests,$(PSRESOURCEOUTPUTDIR)))

.PHONY: pdf
pdf: $(STAMPSPDFFILES)
	$(pushDeploymentArtifact)
