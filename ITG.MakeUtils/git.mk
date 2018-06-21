ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_GIT_DIR
MAKE_GIT_DIR = $(ITG_MAKEUTILS_DIR)

REPOROOT = $(ROOT_PROJECT_DIR)
REPOVERSION = $(REPOROOT).git/logs/HEAD

endif
