#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

GSPSTOPCXFLAGS = -q
PSTOPCXCMDLINE = $(GSCMDLINE) $(GSPSTOPCXFLAGS) \
  -sDEVICE=pcxmono
