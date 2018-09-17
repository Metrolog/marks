#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

GSPSTOPNGFLAGS = -sDEVICE=pngmono -q
PSTOPNGCMDLINE = $(GSCMDLINE) $(GSPSTOPNGFLAGS)
