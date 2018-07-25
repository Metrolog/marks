ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_POWERSHELL_DIR
MAKE_POWERSHELL_DIR = $(MAKE_COMMON_DIR)powershell/

ifeq ($(OS),Windows_NT)

POWERSHELL := powershell

else

POWERSHELL := /usr/bin/pwsh

endif

#POWERSHELLMODULES := '$(MAKE_POWERSHELL_DIR)ITG.MakeUtils/ITG.MakeUtils.psd1'

POWERSHELLFLAGS ?= \
  -NoLogo \
  -NonInteractive \
  -ExecutionPolicy unrestricted

POWERSHELLCMDFLAGS ?= $$(POWERSHELLFLAGS) \
  -Command \
    $$ConfirmPreference = 'High'; \
    $$InformationPreference = 'Continue'; \
    $$ErrorActionPreference = 'Stop'; \
    $$VerbosePreference = 'SilentlyContinue'; \
    $$DebugPreference = 'SilentlyContinue'; \
    @($(call merge,$(COMMA),$(POWERSHELLMODULES))) | Import-Module -ErrorAction 'Stop' -Verbose:$$False;

POWERSHELLSCRIPTFLAGS ?= $(POWERSHELLFLAGS) -File

RUNPOWERSHELLCMD = $(POWERSHELL) $(POWERSHELLCMDFLAGS)

RUNPOWERSHELLSCRIPT = $(POWERSHELL) $(POWERSHELLSCRIPTFLAGS)

ifeq ($(VERBOSE),true)
  VERBOSEFLAGS := -Verbose
else
  VERBOSEFLAGS :=
endif

endif
