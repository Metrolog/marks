#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

STAMPS_DPI     := 1200

STAMPS_YEAR    := 2018
STAMPS_ID      := СП
STAMPS_PERIODS := $(call months,$(call range,1,12)) $(call quarters,$(call range,1,4)) $(call year)
STAMPS_SIGNS   := $(call range,1,2)
STAMPS_SIZE    := 18 mm
STAMPS_VARIANT := 1
STAMPS_TYPE    := verification_stamp
