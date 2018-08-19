#!/usr/bin/make

ifndef __itg_stamps_included
$(error Do not run this file directly. Run 'Makefile' in root project folder.)
endif

$(eval $(call create_verification_stamps, \
	2018, \
	$(call months,$(call range,1,12)) $(call quarters,$(call range,1,4)) $(call year), \
	СП, \
	$(call range,1,2), \
	18 mm, \
	false, \
	$(lastword $(MAKEFILE_LIST)) \
))