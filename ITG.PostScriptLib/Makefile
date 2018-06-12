###
### GNU make Makefile
###

all:

# ITG.MakeUtils

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk
include $(ITG_MAKEUTILS_DIR)/tests.mk
include $(ITG_MAKEUTILS_DIR)/ghostscript.mk
include $(ITG_MAKEUTILS_DIR)/appveyor.mk

PSLIBDIR := .
GSINCDIR := $(GSINCDIR) $(PSLIBDIR)

PSLIBFILES := $(wildcard $(PSLIBDIR)/*.ps)

$(eval $(call definePSBuildTests,$(PSLIBFILES)))
