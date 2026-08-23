# cctest/Makefile - Build all terminal test programs

include ../config.mk

#------------------------------------------------------------------------------
# Auto-discover terminal test directories using Make's wildcard and filtering
#------------------------------------------------------------------------------
ALL_SUBDIRS := $(patsubst ./%,%,$(sort $(dir $(wildcard ./*/))))
UTILS := $(foreach dir,$(ALL_SUBDIRS),$(if $(wildcard $(dir)/Makefile),$(dir)))

#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
.PHONY: all $(UTILS)
all: $(UTILS)

$(UTILS):
	$(Q)$(MAKE) -C $@

#------------------------------------------------------------------------------
# SD Card Installation
#------------------------------------------------------------------------------
.PHONY: sdcard
sdcard: all
	$(Q)$(foreach util,$(UTILS),$(MAKE) -C $(util) sdcard;)

#------------------------------------------------------------------------------
# Clean
#------------------------------------------------------------------------------
.PHONY: clean
clean:
	$(Q)$(foreach util,$(UTILS),$(MAKE) -C $(util) clean;)
