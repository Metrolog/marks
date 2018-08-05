ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TESTS_DIR

MAKE_TESTS_DIR = $(MAKE_COMMON_DIR)tests/

TESTSDIR ?= tests/
TESTSRECIPESDIR = $(AUXDIR)

ifeq ($(SHELLTYPE),PowerShell)

# $(call testPlatformAddTest,testId,status,duration)
testPlatformAddTest = $$$${Function:Add-UnitTest}

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = $$$${Function:Set-UnitTestStatusInformation}

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  Test-UnitTest -TestId '$1' -FileName '$$<' -ScriptBlock { $2 } -StatusWriter $(testPlatformSetStatus) -TestCreator $(testPlatformAddTest);

endif

ifeq ($(SHELLTYPE),sh)

TESTTOOL ?= $(MAKE_TESTS_DIR)itg-makeutils-unit.sh

testPlatformAddTest =
testPlatformSetStatus =

# $(call testPlatformWrapper,testId,testScript,testfile)
testPlatformWrapper = $(TESTTOOL) \
  -n '$1' $(if $3,-f '$3') \
  $(if $(testPlatformAddTest),-a '$(testPlatformAddTest)') \
  $(if $(testPlatformSetStatus),-s '$(testPlatformSetStatus)') \
  -r '$2'

endif

testRecipeFileName = $(TESTSRECIPESDIR)test_recipe.$1-$2.sh

# $(call defineTest,id,targetId,script,deps,orderOnlyDeps,testfile,afterFinish)
define defineTest

$(call testRecipeFileName,$1,$2): $4 $6 | $$(TARGETDIR)
	$$(file > $$@,#!/bin/sh)
	$$(file >> $$@,$3)

.PHONY: test.$1-$2
test.$1-$2: $(call testRecipeFileName,$1,$2) $4 $(if $5,| $5)
	$(call testPlatformWrapper,$$@,$$<,$(strip $6))
	$7

.PHONY: test-$2
test-$2: | test.$1-$2

test: | test-$2

endef

endif
