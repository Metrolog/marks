#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_NUGET_DIR
MAKE_NUGET_DIR = $(MAKE_COMMON_DIR)nuget/

NUGET ?= nuget
NUGET_PACKAGES_DIR ?= packages/

$(NUGET_PACKAGES_DIR)%: $(MAKEFILES)
	$(NUGET) \
    install $(firstword $(subst /,$(__gmsl_space),$(patsubst $(NUGET_PACKAGES_DIR)%,%,$@))) \
    -OutputDirectory $(call winPath,$(NUGET_PACKAGES_DIR)) \
    $(NUGET_PACKAGE_INSTALL_ARGS_$(firstword $(subst /,$(__gmsl_space),$(patsubst $(NUGET_PACKAGES_DIR)%,%,$@)))) \
    -ExcludeVersion

clean::
	$(RMDIR) $(NUGET_PACKAGES_DIR)

endif
