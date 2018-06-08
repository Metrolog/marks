ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

TESTSDIR         ?= tests

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = $$$${Function:Set-UnitTestStatusInformation}

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  Test-UnitTest -TestId '$1' -FileName '$$(call OSPath,$$<)' -ScriptBlock { $2 } -StatusWriter $(testPlatformSetStatus);

# $(call defineTest,id,targetId,script,dependencies)
define defineTest
.PHONY: test.$(1)-$(2)
test.$(1)-$(2): $(4) | $(AUXDIR)
	@Write-Information '==============================================================================='
	$(call testPlatformWrapper,$$@,$3)
	Write-Information '==============================================================================='

.PHONY: test-$(2)
test-$(2): | test.$(1)-$(2)

test: | test-$(2)

endef

endif