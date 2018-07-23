ifndef ITG_MAKEUTILS_LOADED
$(error 'ITG.MakeUtils/common.mk' must be included before any ITG.MakeUtils files.)
endif

ifndef MAKE_PDF_DIR

ifdef SHOW_PDF
  OPENTARGETPDF = $@
else
  OPENTARGETPDF =
endif

endif
