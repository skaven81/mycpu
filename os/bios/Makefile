# bios/Makefile - BIOS build

include ../config.mk

#------------------------------------------------------------------------------
# Source Discovery - Use Make's wildcard and sort
#------------------------------------------------------------------------------
BIOS_SOURCES := $(sort $(wildcard *.asm))
LIBS := $(sort $(wildcard lib/*.asm))
C_SOURCES ?= $(sort $(wildcard *.c) $(wildcard lib/*.c))
C_ASMS := $(C_SOURCES:.c=.asm)
ALL_SOURCES := $(BIOS_SOURCES) $(LIBS) $(C_ASMS)

#------------------------------------------------------------------------------
# Targets
#------------------------------------------------------------------------------
.PHONY: all
all: $(BIOS_HEX) $(BIOS_SYM)

$(BIOS_HEX) $(BIOS_SYM) &: $(ALL_SOURCES) $(OPCODES_FILE) $(MACROS)
	$(Q)echo "  ASM     $(BIOS_HEX) $(BIOS_SYM)"
	$(Q)$(ASSEMBLER) $(ASM_VERBOSE_FLAG) $(ASM_FLAGS) $(ALL_SOURCES) \
		--output $(BIOS_HEX) --output-symbols $(BIOS_SYM) $(ASM_LOG_REDIRECT)

# C compiled assembly
%.asm: %.c
	$(Q)echo "  CC      $<"
	$(Q)$(C_COMPILER) $(C_VERBOSE_FLAG) $(C_FLAGS) --cpp-args='$(C_INCLUDES)' --target-rom $< --output=$@ $(C_LOG_REDIRECT)

#------------------------------------------------------------------------------
# EEPROM Programming
#------------------------------------------------------------------------------
.PHONY: program program1

program: $(BIOS_HEX)
	$(Q)~/serial-eeprom-programmer/programmer write $<

program1: $(BIOS_HEX)
	$(Q)~/serial-eeprom-programmer/programmer --port /dev/ttyUSB1 write $<

.PHONY: clean
clean:
	$(Q)echo "  CLEAN   bios"
	$(Q)rm -f $(FILENAME) $(C_ASMS) *.log *.sym *.hex
