ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

TESTSDIR         ?= tests

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = Write-Information "Test '$1' $2$(if $3, in $3)."

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  $(call testPlatformSetStatus,$1,Running); \
  $$$$sw = [Diagnostics.Stopwatch]::StartNew(); \
  $$$$Status = 'Passed'; \
  try { \
    $2; \
    if ( $$$$LASTEXITCODE -ne 0 ) { throw $$$$LASTEXITCODE; } ;\
  } catch { \
    $$$$Status = 'Failed'; \
  } finally { \
    $$$$sw.Stop(); \
    $(call testPlatformSetStatus,$1,$$$$Status,$$$$($$$$sw.Elapsed)); \
  };

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