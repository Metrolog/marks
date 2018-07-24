ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TESTS_DIR

MAKE_TESTS_DIR = $(ITG_MAKEUTILS_DIR)

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

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformAddTest = $$$${Function:Add-UnitTest}

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = $$$${Function:Set-UnitTestStatusInformation}

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = $2

endif

# $(call defineTest,id,targetId,script,dependencies)
define defineTest
.PHONY: test.$(1)-$(2)
test.$(1)-$(2): $(4)
	@echo '==============================================================================='
	$(call testPlatformWrapper,$$@,$3)
	@echo '==============================================================================='

.PHONY: test-$(2)
test-$(2): | test.$(1)-$(2)

test: | test-$(2)

endef

endif
