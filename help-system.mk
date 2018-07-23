ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_HELP_SYSTEM_DIR
MAKE_HELP_SYSTEM_DIR = $(ITG_MAKEUTILS_DIR)

need-help := $(filter help,$(MAKECMDGOALS))

.PHONY: help
help:: ;
	$(if $(need-help),,$(info Type '$(MAKE) help' to get help.))

define print-help
$(if $(need-help),$(info $1 -- $2))
endef

ifndef SUBPROJECT
_itg_makeutils_print-help = print-help
endif

endif
