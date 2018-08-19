#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

DONT_USE_EPS_BY_DEFAULT = $(true)

# GSPSTOEPSFLAGS =
PSTOEPSCMDLINE = $(GSPSTOEPSCMDLINE)
