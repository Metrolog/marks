ifndef MAKE_TESTS_DIR
MAKE_TESTS_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR   ?= $(MAKE_TESTS_DIR)

include $(realpath $(ITG_MAKEUTILS_DIR)/common.mk)

TESTSDIR         ?= tests

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = Write-Information "Test '$1' $2$(if $3, in $3)."

# $(call testPlatformWrapper,testId,testScript)
# https://stackoverflow.com/questions/8097354/how-do-i-capture-the-output-into-a-variable-from-an-external-process-in-powershe
testPlatformWrapper = \
  $(call testPlatformSetStatus,$1,Running); \
  $$$$sw = [Diagnostics.Stopwatch]::StartNew(); \
  $$$$Passed = $$$$True; \
  $$$$testScriptOutput = ''; \
  $$$$CurrentErrorActionPreference = $$$$ErrorActionPreference; \
  $$$$ErrorActionPreference = 'Continue'; \
  try { \
    $$$$testScriptOutput = & { $2 } 2>&1; \
    $$$$sw.Stop(); \
    $$$$testScriptOutput | ? { $$$$_ -is [System.Management.Automation.ErrorRecord] } | % { $$$$Passed = $$$$False; }; \
  } catch { \
    $$$$sw.Stop(); \
    $$$$Passed = $$$$False; \
  } finally { \
    $$$$testScriptOutput \
    | % { \
      if ( $$$$_ -is [System.Management.Automation.ErrorRecord] ) { \
        $$$$_; \
      } else { \
        Write-Information $$$$_; \
      }; \
    }; \
    if ( $$$$Passed ) { \
      $(call testPlatformSetStatus,$1,'Passed',$$$$($$$$sw.Elapsed)); \
    } else { \
      $(call testPlatformSetStatus,$1,'Failed',$$$$($$$$sw.Elapsed)); \
    }; \
    $$$$ErrorActionPreference = $$$$CurrentErrorActionPreference; \
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