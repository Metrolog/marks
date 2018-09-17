#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

STAMPS_MIRROR  := $(true)
STAMPS_NEGATIVE:= $(true)

STAMPS_YEAR    := 2018
STAMPS_ID      := СП
STAMPS_PERIODS := $(call months,$(call range,1,2))
STAMPS_SIGNS   := $(call range,3,5)
STAMPS_SIZE    := 18 mm
STAMPS_VARIANT := 1
STAMPS_TYPE    := calibration_stamp
