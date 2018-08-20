#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))

$(eval $(call create_stamps, \
  2018, \
  $(call months,$(call range,1,12)) $(call quarters,$(call range,1,4)) $(call year), \
  СП, \
  $(call range,1,2), \
  18 mm, \
  false, \
  verification_stamp, \
  $(THIS_MAKEFILE) \
))

$(eval $(call create_stamps, \
  2018, \
  $(call months,1), \
  СП, \
  10, \
  18 mm, \
  false, \
  verification_stamp_rhombus, \
  $(THIS_MAKEFILE) \
))

$(eval $(call create_stamps, \
  2018, \
  $(call months,$(call range,1,2)), \
  СП, \
  $(call range,3,5), \
  18 mm, \
  false, \
  calibration_stamp, \
  $(THIS_MAKEFILE) \
))
