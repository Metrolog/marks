#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_ZIP_DIR
MAKE_ZIP_DIR = $(MAKE_COMMON_DIR)zip/

ZIP                ?= zip -o -9
TAR                ?= tar

# $(call copyFilesToZIP, targetZIP, sourceFiles, sourceFilesRootDir)
define copyFilesToZIP
$(call assert,$1,Expected zip file name)
$(call assert,$2,Expected source files names)
$(call assert,$3,Expected source files root directory path)
$1:$2 | $$(TARGETDIR)
	cd $3; $(ZIP) -FS -o -r -D $$(abspath $$@) $$(patsubst $3/%, %, $$^)
	$(TOUCH) $$@
endef

endif
