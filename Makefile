#!/usr/bin/make

ROOT_PROJECT_DIR ?= ./
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk

# sub projects

$(eval $(call useSubProject,encodings,encodings, CP1251 CP1253))
$(eval $(call useSubProject,ITG_PostScriptLib,ITG.PostScriptLib))
$(eval $(call useSubProject,fonts,fonts))
$(eval $(call useSubProject,stamps,stamps))
