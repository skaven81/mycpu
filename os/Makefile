# Top-level Makefile

include config.mk

.PHONY: all bios system util cctest
all: bios system util cctest

bios:
	$(Q)$(MAKE) -C $(BIOS_DIR)

# Prerequisites: system and util need bios built
system: bios
	$(Q)$(MAKE) -C $(SYSTEM_DIR)

util: bios
	$(Q)$(MAKE) -C $(UTIL_DIR)

cctest: bios
	$(Q)$(MAKE) -C $(CCTEST_DIR)

#------------------------------------------------------------------------------
# SD Card Installation
#------------------------------------------------------------------------------
.PHONY: sdcard
sdcard: all
	$(Q)$(MAKE) -C $(SYSTEM_DIR) sdcard
	$(Q)$(MAKE) -C $(UTIL_DIR) sdcard
	$(Q)$(MAKE) -C $(CCTEST_DIR) sdcard

#------------------------------------------------------------------------------
# Clean - Use pattern rules to avoid repetition
#------------------------------------------------------------------------------
.PHONY: clean clean-bios clean-system clean-util clean-cctest

clean: clean-bios clean-system clean-util clean-cctest

# Pattern for clean targets
clean-bios:
	$(Q)$(MAKE) -C $(BIOS_DIR) clean
clean-system:
	$(Q)$(MAKE) -C $(SYSTEM_DIR) clean
clean-util:
	$(Q)$(MAKE) -C $(UTIL_DIR) clean
clean-cctest:
	$(Q)$(MAKE) -C $(CCTEST_DIR) clean

#------------------------------------------------------------------------------
# Verbosity Shortcuts - Use target-specific variables
#------------------------------------------------------------------------------
.PHONY: verbose debug

verbose: C_VERBOSE := verbose
verbose: ASM_VERBOSE := verbose
verbose: all

debug: C_VERBOSE := debug
debug: ASM_VERBOSE := debug
debug: all

#------------------------------------------------------------------------------
# Help Target - Use Make's built-in comment parsing
#------------------------------------------------------------------------------
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all       - Build everything (default)"
	@echo "  bios      - Build BIOS only"
	@echo "  system    - Build SYSTEM.ODY only"
	@echo "  util      - Build all utilities"
	@echo "  cctest    - Build all C compiler tests"
	@echo "  sdcard    - Install all to SD card"
	@echo "  clean     - Clean all build artifacts"
	@echo "  verbose   - Build with verbose output to logs"
	@echo "  debug     - Build with debug output to logs"

