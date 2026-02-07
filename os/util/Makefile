# utils/Makefile - Build all utilities

include ../config.mk

#------------------------------------------------------------------------------
# Auto-discover utility directories using Make's wildcard and filtering
#------------------------------------------------------------------------------
# Get all subdirectories, filter only those with Makefiles
ALL_SUBDIRS := $(patsubst ./%,%,$(sort $(dir $(wildcard ./*/))))
UTILS := $(foreach dir,$(ALL_SUBDIRS),$(if $(wildcard $(dir)/Makefile),$(dir)))

#------------------------------------------------------------------------------
# Targets - Use Make's pattern matching
#------------------------------------------------------------------------------
.PHONY: all $(UTILS)
all: $(UTILS)

# Each utility is a phony target that descends into that directory
$(UTILS):
	$(Q)$(MAKE) -C $@

#------------------------------------------------------------------------------
# SD Card Installation - Use Make's foreach
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
