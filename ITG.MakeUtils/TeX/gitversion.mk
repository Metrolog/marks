#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_TEX_GITVERSION_DIR
MAKE_TEX_GITVERSION_DIR = $(MAKE_COMMON_DIR)TeX/

include $(MAKE_COMMON_DIR)git/gitversion.mk

%/version.tex %/version.dtx: $(REPOVERSION) | $(TARGETDIR)
	$(call writeinformation,Generating latex version file "$@"...)
	@$(GIT) log -1 --date=format:%Y/%m/%d --format="format:\
%%\iffalse%n\
%%<*version>%n\
%%\fi%n\
\def\GITCommitterName{%cn}%n\
\def\GITCommitterEmail{%ce}%n\
\def\GITCommitterDate{%cd}%n\
\def\ExplFileDate{%ad}%n\
\def\ExplFileVersion{$(FULLVERSION)}%n\
\def\ExplFileAuthor{%an}%n\
\def\ExplFileAuthorEmail{%ae}%n\
%%\iffalse%n\
%%</version>%n\
%%\fi%n\
" > $@
	$(TOUCH) $@

endif
