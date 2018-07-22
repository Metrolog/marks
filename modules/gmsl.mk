#!/usr/bin/make

ITG_MAKEUTILS_DIR ?= ITG.MakeUtils/
ROOT_PROJECT_DIR ?= ./
REPOROOT = $(ROOT_PROJECT_DIR)
GSMLREPO ?= git://git.code.sf.net/p/gmsl/gmsl
GMSLDIR ?= $(ITG_MAKEUTILS_DIR)GSML/

GIT ?= git

.PHONY: add-gmsl
add-gmsl: $(GMSLDIR)gmsl

$(GMSLDIR)gmsl:
	if   $(GIT) remote | grep gmsl  $(GIT) remote add gmsl -f --no-tags --mirror=fetch $(GSMLREPO)
	$(GIT) subtree add --prefix=$(GMSLDIR) --squash gmsl master
	-$(GIT) remote remove gmsl

.PHONY: update-gmsl
update-gmsl: $(GMSLDIR)gmsl
	$(GIT) subtree pull --prefix=$(GMSLDIR) --squash $(GSMLREPO) master
