#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_APPVEYOR_DIR
MAKE_APPVEYOR_DIR = $(MAKE_COMMON_DIR)appveyor/

include $(MAKE_COMMON_DIR)nuget/nuget.mk

ifdef APPVEYOR

APPVEYORTOOL ?= appveyor

ifeq ($(SHELLTYPE),PowerShell)

writeinformationaux = \
  $(shell Add-AppveyorMessage -Message '$(1)' -Category 'Information' $(if $(2),-Details '$(2)'))

writewarningaux = \
  $(shell Add-AppveyorMessage -Message '$(1)' -Category 'Warning' $(if $(2),-Details '$(2)'))

writeerroraux = \
  $(shell Add-AppveyorMessage -Message '$(1)' -Category 'Error' $(if $(2),-Details '$(2)'))

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
    $$$$Params = $$$$PSBoundParameters; \
    if ( -not $$$$StdOut ) { $$$$Null = $$$$Params.Remove('StdOut'); }; \
    if ( -not $$$$StdErr ) { $$$$Null = $$$$Params.Remove('StdErr'); }; \
    $$$$Params.Duration = $$$$Duration.TotalMilliseconds; \
    Update-AppveyorTest -Framework 'MSTest' @Params; \
    Set-UnitTestStatusInformation \
      -Name $$$$Name -FileName $$$$FileName -Duration $$$$Duration -Outcome $$$$Outcome -StdOut $$$$StdOut -StdErr $$$$StdErr; \
  }

endif

ifeq ($(SHELLTYPE),sh)

writeinformationaux = \
  $(shell appveyor AddMessage "$1" -Category Information $(if $2,-Details "$2"))

writewarningaux = \
  $(shell appveyor AddMessage "$1" -Category Warning $(if $2,-Details "$2"))

writeerroraux = \
  $(shell appveyor AddMessage "$1" -Category Error $(if $2,-Details "$2"))

pushDeploymentArtifactFile = \
  appveyor PushArtifact '$2' -DeploymentName '$1'

pushDeploymentArtifactFiles = \
  $(foreach a,$2,$(call pushDeploymentArtifactFile,$1,$(call OSabsPath,$a)))

pushDeploymentArtifact = $(call pushDeploymentArtifactFiles,$@,$^)

testPlatformAddTest = $(MAKE_APPVEYOR_DIR)on_test_creation.sh
testPlatformSetStatus = $(MAKE_APPVEYOR_DIR)on_test_change.sh

endif

# TODO: удалить это определение. В этом файле не используется.
OPENSSL := C:/OpenSSL-Win64/bin/openssl.exe

else

pushDeploymentArtifactFile =
pushDeploymentArtifact =

endif

SECURE_FILE_TOOL ?= $(NUGET_PACKAGES_DIR)secure-file/tools/secure-file
SECURE_FILES_SECRET ?= password

getEncodedFile = $1.enc

# $(call encodeFile, to, from, secret)
define encodeFile
$(if $1,$1,$(call getEncodedFile,$2)): $2 | $$(SECURE_FILE_TOOL) $$(TARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -encrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

# $(call decodeFile, to, from, secret)
define decodeFile
$1: $(if $2,$2,$(call getEncodedFile,$1)) | $$(SECURE_FILE_TOOL) $$(TARGETDIR)
	$$(SECURE_FILE_TOOL) \
    -secret $$(if $3,$3,$$(SECURE_FILES_SECRET)) \
    -decrypt $$(call winPath,$$<) \
    -out $$(call winPath,$$@)

endef

endif
