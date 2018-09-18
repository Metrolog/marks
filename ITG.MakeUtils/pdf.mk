#!/usr/bin/make

ifndef __itg_makeutils_included
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_PDF_DIR

ifdef SHOW_PDF
  ifeq ($(OS),Windows_NT)
    ifeq ($(is_cygwin),$(true))
      OPENTARGETPDF =
    else
      OPENTARGETPDF = $@
    endif
  else
    OPENTARGETPDF =
  endif
else
  OPENTARGETPDF =
endif

endif
