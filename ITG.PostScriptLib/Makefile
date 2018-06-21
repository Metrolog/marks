#!/usr/bin/make

all:

# ITG.MakeUtils

ROOT_PROJECT_DIR ?= ../
ITG_MAKEUTILS_DIR ?= $(ROOT_PROJECT_DIR)ITG.MakeUtils/
include $(ITG_MAKEUTILS_DIR)common.mk
include $(ITG_MAKEUTILS_DIR)tests.mk
include $(ITG_MAKEUTILS_DIR)ghostscript.mk
include $(ITG_MAKEUTILS_DIR)appveyor.mk

PSLIBDIR := ./
GSINCDIR := $(GSINCDIR) $(PSLIBDIR)

PSLIBFILES := $(wildcard $(PSLIBDIR)*.ps)

$(eval $(call definePostScriptTests,$(PSLIBFILES)))
