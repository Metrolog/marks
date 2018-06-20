ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GITVERSION_BUILDCACHE_DIR
MAKE_GITVERSION_BUILDCACHE_DIR = $(ITG_MAKEUTILS_DIR)

GITVERSIONVARS := Major Minor Patch PreReleaseTag PreReleaseTagWithDash PreReleaseLabel PreReleaseNumber \
  BuildMetaData BuildMetaDataPadded FullBuildMetaData MajorMinorPatch SemVer LegacySemVer LegacySemVerPadded \
  AssemblySemVer FullSemVer InformationalVersion BranchName Sha \
  NuGetVersionV2 NuGetVersion \
  CommitsSinceVersionSource CommitsSinceVersionSourcePadded CommitDate

%/version.mk: $(REPOVERSION)
	$(file > $@,#version data file)
	$(foreach var,$(GITVERSIONVARS),$(file >> $@,export $(call setvariable,$(var),$(GitVersion_$(var)))))
	touch $@

endif
