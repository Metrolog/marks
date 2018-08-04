ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TESTS_DIR

MAKE_TESTS_DIR = $(MAKE_COMMON_DIR)tests/

TESTSDIR ?= tests/

ifeq ($(SHELLTYPE),PowerShell)

# $(call testPlatformSetStatus,testId,status,duration)
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
testPlatformWrapper = $(TESTTOOL) -n "$1" $(if $3,-f "$3") $(if $(testPlatformAddTest),-a '$(testPlatformAddTest)') $(if $(testPlatformSetStatus),-s '$(testPlatformSetStatus)') "$2"

endif

# $(call defineTest,id,targetId,script,dependencies,testfile)
define defineTest
.PHONY: test.$(1)-$(2)
test.$(1)-$(2): $(4)
	$(call testPlatformWrapper,$$@,$3,$$(strip $5))

.PHONY: test-$(2)
test-$(2): | test.$(1)-$(2)

test: | test-$(2)

endef

endif
