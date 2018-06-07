###
### GNU make Makefile
###

ITG_MAKEUTILS_DIR  ?= ITG.MakeUtils
include $(ITG_MAKEUTILS_DIR)/common.mk

# sub projects

$(eval $(call useSubProject,encodings,encodings, CP1251 CP1253))
$(eval $(call useSubProject,stamps,stamps))
