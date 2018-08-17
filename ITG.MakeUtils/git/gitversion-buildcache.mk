#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GITVERSION_BUILDCACHE_DIR

include $(MAKE_COMMON_DIR)git/git.mk

MAKE_GITVERSION_BUILDCACHE_DIR = $(MAKE_GIT_DIR)

GITVERSIONVARS := Major Minor Patch PreReleaseTag PreReleaseTagWithDash PreReleaseLabel PreReleaseNumber \
  BuildMetaData BuildMetaDataPadded FullBuildMetaData MajorMinorPatch SemVer LegacySemVer LegacySemVerPadded \
  AssemblySemVer FullSemVer InformationalVersion BranchName Sha \
  NuGetVersionV2 NuGetVersion \
  CommitsSinceVersionSource CommitsSinceVersionSourcePadded CommitDate

%/version.mk: $(REPOVERSION)
	$(file > $@,#version data file)
	$(foreach var,$(GITVERSIONVARS),$(file >> $@,export $(call setvariable,$(var),$(GitVersion_$(var)))))
	$(TOUCH) $@

endif
