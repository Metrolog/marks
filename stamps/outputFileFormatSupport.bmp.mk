#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

GSPSTOBMPFLAGS = -sDEVICE=bmpmono -q
PSTOBMPCMDLINE = $(GSCMDLINE) $(GSPSTOBMPFLAGS)
