ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

TESTSDIR         ?= tests

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = Write-Information "Test '$1' $2$(if $3, in $3)."

# $(call testPlatformWrapper,testId,testScript)
testPlatformWrapper = \
  set +e; \
  $(call testPlatformSetStatus,$1,Running); \
  START_TIME=$$$$(($$$$(date +%s%3N))); \
  ( $2 ); \
  EXIT_CODE=$$$$?; \
  FINISH_TIME=$$$$(($$$$(date +%s%3N))); \
  DURATION=$$$$(($$$$FINISH_TIME-$$$$START_TIME)); \
  if [[ $$$$EXIT_CODE -eq 0 ]]; then \
    $(call testPlatformSetStatus,$1,Passed,$$$$DURATION); \
  else \
    $(call testPlatformSetStatus,$1,Failed,$$$$DURATION); \
  fi; \
  exit $$$$EXIT_CODE;

testPlatformWrapper = \
  $(call testPlatformSetStatus,$1,Running); \
  $$$$sw = [Diagnostics.Stopwatch]::StartNew(); \
  try { \
    $2; \
    $$$$sw.Stop(); \
    $(call testPlatformSetStatus,$1,Passed,$$$$($$$$sw.Elapsed)); \
  } catch { \
    $$$$sw.Stop(); \
    $(call testPlatformSetStatus,$1,Failed,$$$$($$$$sw.Elapsed)); \
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