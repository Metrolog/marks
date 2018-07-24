ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GITVERSION_DIR
MAKE_GITVERSION_DIR = $(ITG_MAKEUTILS_DIR)

include $(ITG_MAKEUTILS_DIR)git.mk

GITVERSION ?= gitversion

export GITVERSIONMAKEFILE ?= $(abspath $(AUXDIR)version.mk)

$(GITVERSIONMAKEFILE): $(REPOVERSION) | $(TARGETDIR)
	$(call writeinformation,Generating version data file "$@" with GitVersion...)
	$(GITVERSION) /exec $(MAKE) /execargs "--makefile=$(MAKE_GITVERSION_DIR)gitversion-buildcache.mk $@"

ifeq ($(filter clean,$(MAKECMDGOALS)),)
include $(GITVERSIONMAKEFILE)
endif

GIT_BRANCH          := $(BranchName)
export VERSION      := $(Major).$(Minor)
export FULLVERSION  := $(SemVer)
export MAJORVERSION := $(Major)
export MINORVERSION := $(Minor)

endif
