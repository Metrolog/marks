ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_ZIP_DIR
MAKE_ZIP_DIR = $(ITG_MAKEUTILS_DIR)

# TODO: переписать ZIP на PowerShell
ZIP                ?= zip -o -9
# TODO: переписать TAR на PowerShell
TAR                ?= tar

# TODO: переписать на PowerShell. Такое соединение через && - только для Windows
# TODO: и выполнить в одну строку
# $(call copyFilesToZIP, targetZIP, sourceFiles, sourceFilesRootDir)
define copyFilesToZIP
$(call _assert_not_null,$1)
$(call _assert_not_null,$2)
$(call _assert_not_null,$3)
$1:$2
	$$(MAKETARGETDIR)
	cd $3 && $(ZIP) -FS -o -r -D $$(abspath $$@) $$(patsubst $3/%, %, $$^)
	$(TOUCH) $$@
endef

endif
