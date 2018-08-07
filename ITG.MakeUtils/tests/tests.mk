#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TESTS_DIR

MAKE_TESTS_DIR = $(MAKE_COMMON_DIR)tests/
__itg_makeutils_tests_included:=$(true)

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

TESTS_MAKEFILE_LIST:=$(empty_set)

# $(call define_test,id,targetId,script,deps,testTargetFile,orderOnlyDeps,testfile,afterFinish)
define define_test

$(TESTSRECIPESDIR)test.$1-$2.mk: $(call set_remove,$(TESTS_MAKEFILE_LIST),$(call set_create,$(MAKEFILE_LIST))) | $$(TARGETDIR)
	$$(file > $$@,#!/usr/bin/make)
	$$(file >> $$@,)
	$$(file >> $$@,.PHONY: test.$1-$2.recipe)
	$$(file >> $$@,test.$1-$2.recipe: $(call uniq,$5 $7 $4) $(if $6,| $6))
	$$(file >> $$@,	$3)
	$$(file >> $$@,)
	$$(file >> $$@,.PHONY: test.$1-$2)
	$$(file >> $$@,test.$1-$2: $(call uniq,$7 $4) $(if $6,| $6))
	$$(file >> $$@,	$$(call testPlatformWrapper,$$$$@,$$(MAKE) test.$1-$2.recipe,$(strip $7)))
	$$(if $8,$$(file >> $$@,	$8))
	$$(file >> $$@,)
	$$(file >> $$@,.PHONY: test-$2)
	$$(file >> $$@,test-$2: | test.$1-$2)
	$$(file >> $$@,)
	$$(file >> $$@,test: | test-$2)

$(call include_makefile_if_not_clean,$(TESTSRECIPESDIR)test.$1-$2.mk)

TESTS_MAKEFILE_LIST:=$(call set_insert,$(TESTSRECIPESDIR)test.$1-$2.mk,$(TESTS_MAKEFILE_LIST))

endef

endif
