#!/usr/bin/make

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk
include $(ITG_MAKEUTILS_DIR)powershell.mk

all:: CP1251 CP1253

AGLFNFILE ?= agl-aglfn/aglfn.txt

# download unicode mappings

MAPPINGSDIR = maps/

$(MAPPINGSDIR)MAPPINGS/%.TXT:
	$(call writeinformation,Downloading file "$(@F)"...)
	$(MAKETARGETDIR)
	$(CURL) "http://www.unicode.org/Public/MAPPINGS/$*.TXT" -o '$@'

$(OUTPUTDIR)%.ps:
	$(call writeinformation,Creating PostScript encoding file "$(@F)" from "$<"...)
	$(MAKETARGETDIR)
	$(RUNPOWERSCRIPT) ./New-PostscriptEncodingTable.ps1 -EncodingSourceFilePath '$<' -FilePath '$@' $(VERBOSEFLAGS)

# $(call mapPSEncodingFileToSource, uri, encoding)
define mapPSEncodingFileToSource

export $(2)TARGET := $(OUTPUTDIR)$(2)Encoding.ps
$(call pushArtifactTargets,$(2)TARGET)

$(OUTPUTDIR)$(2)Encoding.ps: $(MAPPINGSDIR)MAPPINGS/$(1)/$(2).TXT

.PHONY: $2
$2: $$($(2)TARGET)

endef

$(foreach encoding, CP037 CP500 CP875 CP1026, \
  $(eval $(call mapPSEncodingFileToSource,VENDORS/MICSFT/EBCDIC,$(encoding))) \
)

$(foreach encoding, CP437 CP737 CP775 CP850 CP852 CP855 CP857 CP860 CP861 CP862 CP863 CP864 CP865 CP866 CP869 CP874, \
  $(eval $(call mapPSEncodingFileToSource,VENDORS/MICSFT/PC,$(encoding))) \
)

$(foreach encoding, CP874 CP932 CP936 CP949 CP950 CP1250 CP1251 CP1252 CP1253 CP1254 CP1255 CP1256 CP1257 CP1258, \
  $(eval $(call mapPSEncodingFileToSource,VENDORS/MICSFT/WINDOWS,$(encoding))) \
)

$(foreach encoding, KOI8-R KOI8-U, \
  $(eval $(call mapPSEncodingFileToSource,VENDORS/MISC,$(encoding))) \
)

clean::
	$(RMDIR) $(MAPPINGSDIR)
