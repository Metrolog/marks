###
### GNU make Makefile
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

# sub projects

$(eval $(call useSubProject,stamps,$(SOURCESDIR)/stamps))
