#!/usr/bin/make

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk

STAMPFONTFILESDIR := ./
STAMPFONTFILES := $(wildcard *.pt3)

$(eval $(call pushArtifactTargets,STAMPFONTFILES))
$(eval $(call pushArtifactTargets,STAMPFONTFILESDIR))
