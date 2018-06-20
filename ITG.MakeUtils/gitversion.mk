ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GITVERSION_DIR
MAKE_GITVERSION_DIR = $(ITG_MAKEUTILS_DIR)

GITVERSION ?= gitversion

export GITVERSIONMAKEFILE ?= $(abspath $(AUXDIR)version.mk)

$(GITVERSIONMAKEFILE): $(REPOVERSION)
	$(call writeinformation,Generating version data file "$@" with GitVersion...)
	$(MAKETARGETDIR)
	$(GITVERSION) /exec $(MAKETOOL) /execargs "--makefile=$(MAKE_GITVERSION_DIR)gitversion-buildcache.mk $@"
	$(call writeinformation,File "$@" is ready.)

ifeq ($(filter clean,$(MAKECMDGOALS)),)
include $(GITVERSIONMAKEFILE)
endif

GIT_BRANCH          := $(BranchName)
export VERSION      := $(Major).$(Minor)
export FULLVERSION  := $(SemVer)
export MAJORVERSION := $(Major)
export MINORVERSION := $(Minor)

endif
