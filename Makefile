#!/usr/bin/make

ROOT_PROJECT_DIR ?= ./
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)git/git.mk
include $(ITG_MAKEUTILS_DIR)appveyor/appveyor.mk

# sub projects

$(eval $(call useExternalSubProjectAsSubtree,makeutils,git@github.com:IT-Service/ITG.MakeUtils.git,$(ITG_MAKEUTILS_DIR)))
$(eval $(call useExternalSubProjectAsSubtree,aglfn,https://github.com/adobe-type-tools/agl-aglfn.git,encodings/agl-aglfn/))

$(eval $(call useSubProject,encodings,encodings, CP1251 CP1253))
$(eval $(call useSubProject,ITG_PostScriptLib,ITG.PostScriptLib))
$(eval $(call useSubProject,fonts,fonts))
$(eval $(call useSubProject,stamps,stamps))
