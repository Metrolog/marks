#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TESTS_DIR

MAKE_TESTS_DIR = $(MAKE_COMMON_DIR)tests/
__itg_makeutils_tests_included:=$(true)

TESTSDIR ?= tests/
TESTSOUTPUTDIR ?= $(AUXDIR)tests/
TESTSRECIPESDIR = $(AUXDIR)
export TESTSSTATUSLOG = $(ROOT_PROJECT_DIR)$(AUXDIR)tests_status.txt

ifeq ($(is_root_project),$(true))

$(TESTSSTATUSLOG): | $(TARGETDIR)
	$(file > $@,Tests results at $(shell date +%c):)
	$(TOUCH) $@

check: $(TESTSSTATUSLOG)

check:
	$(file >> $(TESTSSTATUSLOG),)
	@echo '==============================================================================='
	@cat '$(TESTSSTATUSLOG)'
	@echo '==============================================================================='
	rm '$(TESTSSTATUSLOG)'

endif

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

# $(call define_test,id,targetId,script,deps,testTargetFile,orderOnlyDeps,testfile,afterFinish)
define __define_test_aux

.PHONY: test.$(strip $1)-$(strip $2).recipe
test.$(strip $1)-$(strip $2).recipe: $(call uniq,$5 $7 $4) $(if $6,| $6)
$(if $(strip $3),	$(strip $3))

.PHONY: test.$(strip $1)-$(strip $2)
test.$(strip $1)-$(strip $2): $(call uniq,$7 $4) $(if $6,| $6)
	$$(call testPlatformWrapper,$$@,$$(MAKE) test.$(strip $1)-$(strip $2).recipe,$(strip $7))
$(if $(strip $8),	$(strip $8))

.PHONY: test-$(strip $2)
test-$(strip $2): | test.$(strip $1)-$(strip $2)

check: | test-$(strip $2)

endef

define_test = $(call call_as_check_makefile,$$(call __define_test_aux,$1,$2,$3,$4,$5,$6,$7,$8),test.$(strip $1)-$(strip $2).mk)

endif
