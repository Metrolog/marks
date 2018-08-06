#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GIT_DIR
MAKE_GIT_DIR = $(MAKE_COMMON_DIR)git/

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
maintainer-add-$(strip $1): $$(call print-help,maintainer-add-$(strip $1),This target is intended to be used by a maintainer of the package. Not by ordinary users. Add repository from $$($(strip $1)_REPOSITORY_URL) to $$($(strip $1)_DIR) as git subtree.)
	$(GIT) subtree add --prefix=$$($(strip $1)_DIR) --squash $$($(strip $1)_REPOSITORY_URL) master

.PHONY: maintainer-pull-$(strip $1)
maintainer-pull-$(strip $1): $$(call print-help,maintainer-pull-$(strip $1),This target is intended to be used by a maintainer of the package. Not by ordinary users. Pull changes from remote repository $$($(strip $1)_REPOSITORY_URL) to git subtree $$($(strip $1)_DIR).)
	$(GIT) subtree pull --prefix=$$($(strip $1)_DIR) --squash $$($(strip $1)_REPOSITORY_URL) master

.PHONY: maintainer-push-$(strip $1)
maintainer-push-$(strip $1): $$(call print-help,maintainer-push-$(strip $1),This target is intended to be used by a maintainer of the package. Not by ordinary users. Push changes from this repository to remote $$($(strip $1)_REPOSITORY_URL) from git subtree $$($(strip $1)_DIR).)
	$(GIT) subtree push --prefix=$$($(strip $1)_DIR) $$($(strip $1)_REPOSITORY_URL) master

endef

endif
