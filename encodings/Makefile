###
### GNU make Makefile
###

all: CP1251 CP1253

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ../ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

# tools

AGLFNFILE ?= $(call OSabsPath,agl-aglfn/aglfn.txt)

# download unicode mappings

$(AUXDIR)/MAPPINGS/%.TXT:
	$(info Download file "$(@F)"...)
	$(MAKETARGETDIR)
	$(call psExecuteCommand, \
    "Congratulations! PowerShell is installed at $PSHOME"; \
    Invoke-WebRequest \
      -Uri 'http://www.unicode.org/Public/MAPPINGS/$*.TXT' \
      -OutFile '$@' \
      -Verbose \
    ; \
  )
	@touch $@

$(OUTPUTDIR)/%.ps:
	$(info Create PostScript encoding file "$(@F)" from "$<"...)
	$(MAKETARGETDIR)
	$(PowerShell) \
    -File New-PostscriptEncodingTable.ps1 \
      -EncodingSourceFilePath $(call OSPath,$<) \
      -FilePath '$@' \
      -ErrorAction Stop \
      -Verbose

# $(call mapPSEncodingFileToSource, uri, encoding)
define mapPSEncodingFileToSource

export $(2)TARGET := $(OUTPUTDIR)/$(2).ps
$(call pushArtifactTargets,$(2)TARGET)

$(OUTPUTDIR)/$(2).ps: $(AUXDIR)/MAPPINGS/$(1)/$(2).TXT

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
