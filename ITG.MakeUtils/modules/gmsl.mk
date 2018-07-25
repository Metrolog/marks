#!/usr/bin/make

ROOT_PROJECT_DIR ?= ./
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(MAKE_COMMON_DIR)common.mk
include $(MAKE_COMMON_DIR)git/git.mk

# sub projects

$(eval $(call useExternalSubProjectAsSubtree,gmsl,git://git.code.sf.net/p/gmsl/gmsl,$(MAKE_COMMON_DIR)GMSL/))
