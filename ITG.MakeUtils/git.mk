ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GIT_DIR
MAKE_GIT_DIR = $(ITG_MAKEUTILS_DIR)

REPOROOT = $(ROOT_PROJECT_DIR)
REPOVERSION = $(REPOROOT).git/logs/HEAD

GIT ?= git

# $(call useExternalSubProjectAsSubtree,projectSlug,projectRepoURL,projectDir)
define useExternalSubProjectAsSubtree

$(call assert,$1,Expected project slug)
$(call assert,$2,Expected project repository URL)

$(strip $1)_REPOSITORY_URL ?= $2
$(strip $1)_DIR := $(if $3,$(patsubst ./%,%,$(strip $3)),$(strip $1))

.PHONY: maintainer-add-$(strip $1)
maintainer-add-$(strip $1):
	$(GIT) subtree add --prefix=$$($(strip $1)_DIR) --squash $$($(strip $1)_REPOSITORY_URL) master

.PHONY: maintainer-update-$(strip $1)
maintainer-update-$(strip $1):
	$(GIT) subtree pull --prefix=$$($(strip $1)_DIR) --squash $$($(strip $1)_REPOSITORY_URL) master

.PHONY: maintainer-push-$(strip $1)
maintainer-push-$(strip $1):
	$(GIT) subtree push --prefix=$$($(strip $1)_DIR) $$($(strip $1)_REPOSITORY_URL) master

endef

endif
