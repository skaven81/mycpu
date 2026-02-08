# rules.mk - Reusable build rules and patterns
# Include this after setting component-specific variables

#------------------------------------------------------------------------------
# Automatic Variables - Use Make's built-in functions
#------------------------------------------------------------------------------
# notdir and CURDIR are Make built-ins
DIRNAME ?= $(notdir $(CURDIR))

# Use Make's text transformation functions instead of shell
OUTPUT_NAME ?= $(shell echo $(DIRNAME) | tr '[:lower:]' '[:upper:]')
FILENAME ?= $(OUTPUT_NAME).ODY

#------------------------------------------------------------------------------
# Build Target - Use automatic variables and order-only prerequisites
#------------------------------------------------------------------------------
.PHONY: all
all: $(FILENAME)

#------------------------------------------------------------------------------
# Source Discovery - Pure Make functions
#------------------------------------------------------------------------------
# sort removes duplicates and sorts (Make built-in)
C_SOURCES ?= $(sort $(wildcard *.c))
# ASM files built from C sources (ephemeral)
C_ASMS := $(C_SOURCES:.c=.asm)
# ASM sources are any ASMs that weren't built by a compiler
ASM_SOURCES ?= $(sort $(filter-out $(C_ASMS), $(wildcard *.asm)))

# All ASM files
ALL_ASMS := $(ASM_SOURCES) $(C_ASMS)

# Make all non-BIOS .asms depend on symbol table and opcodes
$(ALL_ASMS): $(BIOS_SYM) $(OPCODES_FILE)
# Make compiled .asm files depend on BIOS artifacts automatically
$(C_ASMS): $(BIOS_SYM) $(OPCODES_FILE)

$(BIOS_SYM):
	$(Q)$(MAKE) -C $(BIOS_DIR) $(BIOS_SYM)

$(OPCODES_FILE): $(OPCODES_GEN)
	$(Q)echo "  GEN     $@"
	$(Q)bash -c "$< > $@"

#------------------------------------------------------------------------------
# Standard Pattern Rules - Use Make's pattern rule system
#------------------------------------------------------------------------------
# Pattern rule: any .c -> .asm (Make built-in feature)
%.asm: %.c
	$(Q)echo "  CC      $<"
	$(Q)$(C_COMPILER) $(C_VERBOSE_FLAG) $(C_FLAGS) --cpp-args='$(C_INCLUDES)' $< --output=$@ $(C_LOG_REDIRECT)

#------------------------------------------------------------------------------
# Common Phony Targets - Use .PHONY (Make built-in)
#------------------------------------------------------------------------------
.PHONY: clean sdcard clean-opcodes

clean:
	$(Q)echo "  CLEAN   $(DIRNAME)"
	$(Q)rm -f $(FILENAME) $(C_ASMS) *.log *.sym *.hex

clean-opcodes:
	$(Q)echo "  CLEAN   $(OPCODES_FILE)"
	$(Q)rm -f $(OPCODES_FILE)

# Use target-specific variable for installation subdir
sdcard: $(FILENAME)
	$(Q)test -d $(INSTALL_DIRECTORY) || ( echo "ERROR: $(INSTALL_DIRECTORY) does not exist" && exit 1 )
	$(Q)mkdir -p $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)
	$(Q)echo "  INSTALL $(FILENAME) -> $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$(FILENAME)"
	$(Q)cp $(FILENAME) $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$(FILENAME)

#------------------------------------------------------------------------------
# Validation Helpers - Use Make's built-in string functions
#------------------------------------------------------------------------------
# Use Make's $(words) and $(wordlist) instead of shell wc
VALIDATE_NAME_LENGTH = $(if $(word $(MAX_CMD_LENGTH),$(subst x, ,$(subst $(space),,$(DIRNAME)))),\
	$(error Command name '$(DIRNAME)' exceeds $(MAX_CMD_LENGTH) characters))

# Standard ODY build declaration
$(FILENAME): $(OPCODES_FILE) $(ALL_ASMS) $(BIOS_SYM)
	$(VALIDATE_NAME_LENGTH)
	$(Q)echo "  ASM     $@"
	$(Q)$(ASSEMBLER) $(ASM_VERBOSE_FLAG) $(ODY_ASM_FLAGS) \
		--odyssey-target $(MEM_TARGET) \
        --symbols $(BIOS_SYM) \
        --opcodes $(OPCODES_FILE) \
		--output $@ \
        $(ALL_ASMS) $(ASM_LOG_REDIRECT)

# Call this in your recipe with: $(VALIDATE_NAME_LENGTH)
