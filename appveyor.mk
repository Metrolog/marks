ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ITG_MAKEUTILS_DIR ?= $(MAKE_APPVEYOR_DIR)

include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/nuget.mk

ifdef APPVEYOR

APPVEYORTOOL ?= appveyor

ifeq ($(CI_LINUX),true)

POWERSHELLMODULES  := $(POWERSHELLMODULES), \
  '/opt/appveyor/build-agent/AppVeyor.BuildAgent.PowerShell.dll'

endif

writeinformationaux = \
  Add-AppveyorMessage -Message '$(1)' -Category 'Information' -Details '$(2)';

writewarningaux = \
  Add-AppveyorMessage -Message '$(1)' -Category 'Warning' -Details '$(2)';

writeerroraux = \
  Add-AppveyorMessage -Message '$(1)' -Category 'Error' -Details '$(2)';

pushDeploymentArtifactFile = \
  Push-AppveyorArtifact $(VERBOSEFLAGS) -DeploymentName '$(1)' -Path '$(2)';

pushDeploymentArtifactFiles = \
  $(foreach artifact,$(2), $(call pushDeploymentArtifactFile,$(1),$(call OSabsPath,$(artifact))))

pushDeploymentArtifact = $(call pushDeploymentArtifactFiles,$@,$^)

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformAddTest = \
  { param ( $$$$Name, $$$$FileName ) \
    Add-AppveyorTest -Framework 'MSTest' \
      -Name $$$$Name -FileName $$$$FileName; \
  }

# $(call testPlatformSetStatus,testId,status,duration)
testPlatformSetStatus = \
  { param ( $$$$Name, $$$$FileName, $$$$Outcome, [System.TimeSpan] $$$$Duration = 0, $$$$StdOut = '', $$$$StdErr = '' ) \
    Set-UnitTestStatusInformation \
      -Name $$$$Name -FileName $$$$FileName -Duration $$$$Duration -Outcome $$$$Outcome -StdOut $$$$StdOut -StdErr $$$$StdErr; \
    $$$$Params = $$$$PSBoundParameters; \
    if ( -not $$$$StdOut ) { $$$$Null = $$$$Params.Remove('StdOut'); }; \
    if ( -not $$$$StdErr ) { $$$$Null = $$$$Params.Remove('StdErr'); }; \
    $$$$Params.Duration = $$$$Duration.TotalMilliseconds; \
    Update-AppveyorTest -Framework 'MSTest' @Params; \
  }

# todo: удалить это определение. В этом файле не используется.
OPENSSL := $(call shellPath,C:\OpenSSL-Win64\bin\openssl.exe)

else

pushDeploymentArtifactFile =
pushDeploymentArtifact =

endif

SECURE_FILE_TOOL ?= $(NUGET_PACKAGES_DIR)/secure-file/tools/secure-file
SECURE_FILES_SECRET ?= password

getEncodedFile = $1.enc

# $(call encodeFile, to, from, secret)
define encodeFile
$(if $1,$1,$(call getEncodedFile,$2)): $2 | $$(SECURE_FILE_TOOL)
	$$(MAKETARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -encrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

# $(call decodeFile, to, from, secret)
define decodeFile
$1: $(if $2,$2,$(call getEncodedFile,$1)) | $$(SECURE_FILE_TOOL)
	$$(MAKETARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -decrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

endif
