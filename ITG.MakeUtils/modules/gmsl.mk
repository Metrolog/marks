#!/usr/bin/make

ROOT_PROJECT_DIR ?= ./
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)git/git.mk

# sub projects

$(eval $(call useExternalSubProjectAsSubtree,gmsl,https://github.com/gmsl/gmsl.git,$(MAKE_COMMON_DIR)GMSL/))
