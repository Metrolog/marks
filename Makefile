###
### GNU make Makefile for build GOST 2.304-81 fonts files
###

FONT				?= GOST2.304-81TypeA

SPACE				= $(empty) $(empty)
SRCDIR				:= sources/
OUTPUTDIR			:= release
TTFDIR				:= $(OUTPUTDIR)/ttf
AUXDIR				:= obj
TOOLSDIR			:= tools/

# setup tools

TTFAUTOHINTOPTIONS	:= \
	--hinting-range-min=8 --hinting-range-max=88 --hinting-limit=220 --increase-x-height=22 \
	--windows-compatibility \
	--composites \
	--no-info

ifeq ($(OS),Windows_NT)
	RM				:= del /S/Q
	RMDIR			:= rmdir /S/Q
	MAKETARGETDIR	= $(foreach d,$(subst /, ,${@D}),@mkdir $d && @cd $d && ) @echo dir "${@D}" created... 
	MAKETARGETDIR2	= cd $(dir ${@D}) && mkdir $(notdir ${@D})
	TOUCH			= @echo . >
	FONTFORGE		?= "%ProgramFiles(x86)%/FontForgeBuilds/bin/fontforge"
	TTFAUTOHINT		?= "%ProgramFiles(x86)%/ttfautohint/ttfautohint" $(TTFAUTOHINTOPTIONS)
else
	RM				:= rm
	RMDIR			:= rmdir
	MAKETARGETDIR	= mkdir -p ${@D}
	MAKETARGETDIR2	= MAKETARGETDIR
	TOUCH			= touch
	FONTFORGE		?= fontforge
	TTFAUTOHINT		?= ttfautohint $(TTFAUTOHINTOPTIONS)
endif

## grab a version number from the repository (if any) that stores this.
## * REVISION is the current revision number (short form, for inclusion in text)
## * VCSTURD is a file that gets touched after a repo update
REVISION			:= $(shell git rev-parse --short HEAD)
GIT_BRANCH			:= $(shell git symbolic-ref HEAD)
VCSTURD				:= $(subst $(SPACE),\ ,$(shell git rev-parse --git-dir)/$(GIT_BRANCH))
VERSION				:= $(lastword $(subst /, ,$(GIT_BRANCH)))

# directories rules

dirstate:;

%/dirstate:
	$(info Directory "${@D}" creating...)
	$(MAKETARGETDIR2)
	@$(TOUCH) $@

$(TTFDIR)/dirstate: $(OUTPUTDIR)/dirstate

###

.DEFAULT_GOAL		:= all

.PHONY: all clean ttf

all: ttf

# generate aux .sfd files

FULLSTROKEDFONTSFD	:= $(AUXDIR)/$(FONT)-stroked-full-aux.sfd
FFBUILDSTROKEDSFD	:= $(TOOLSDIR)build-stroked-sfd.pe

$(FULLSTROKEDFONTSFD): $(SRCDIR)$(FONT).sfd $(FFBUILDSTROKEDSFD) $(AUXDIR)/dirstate
	$(info Build additional glyphs, additional .sfd processing for stroked font...)
	$(FONTFORGE) -script $(FFBUILDSTROKEDSFD) $< $@ $(VERSION)

# generate aux regular .sfd file

REGULARFONTSFD		:= $(AUXDIR)/$(FONT)-Regular.sfd
FFBUILDREGULARSFD	:= $(TOOLSDIR)build-regular-sfd.pe

$(REGULARFONTSFD): $(FULLSTROKEDFONTSFD) $(FFBUILDREGULARSFD) $(AUXDIR)/dirstate
	$(info Build outline regular font .sfd file...)
	$(FONTFORGE) -script $(FFBUILDREGULARSFD) $< $@

# all FontForge aux projects

FONTALLSFD		:= $(REGULARFONTSFD)

# build True Type fonts

FFGENERATETTF		:= $(TOOLSDIR)generate-ttf.pe

TTFTARGETS			:= $(FONTALLSFD:$(AUXDIR)/%.sfd=$(TTFDIR)/%.ttf)
TTFNOAUTOHINTTARGETS:= $(TTFTARGETS:$(TTFDIR)/%.ttf=$(AUXDIR)/%.ttf)

$(AUXDIR)/%.ttf: $(AUXDIR)/%.sfd $(FFGENERATETTF)
	$(info Generate .ttf font "$@"...)
	$(FONTFORGE) -script $(FFGENERATETTF) $< $@
	
$(TTFDIR)/%.ttf: $(AUXDIR)/%.ttf $(TTFDIR)/dirstate
	$(info Autohinting and autoinstructing .ttf font "$@" (by ttfautohint)...)
	$(TTFAUTOHINT) $< $@

ttf: $(TTFTARGETS)

# clean projects

clean:
	$(info Erase aux and release directories...)
	-$(RMDIR) $(AUXDIR)
	-$(RMDIR) $(OUTPUTDIR)
