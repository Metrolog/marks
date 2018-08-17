#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GITVERSION_DIR

include $(MAKE_COMMON_DIR)git/git.mk

MAKE_GITVERSION_DIR = $(MAKE_GIT_DIR)

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
