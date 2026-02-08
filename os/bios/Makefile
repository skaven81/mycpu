# bios/Makefile - BIOS build

include ../config.mk

#------------------------------------------------------------------------------
# Source Discovery - Use Make's wildcard and sort
#------------------------------------------------------------------------------
BIOS_C := $(sort $(wildcard *.c))
BIOS_C_ASM := $(BIOS_C:.c=.asm)
BIOS_ASM := $(filter-out $(BIOS_C_ASM), $(wildcard *.asm))
BIOS_SOURCES := $(sort $(BIOS_C_ASM) $(BIOS_ASM))

LIBS_C := $(sort $(wildcard lib/*.c))
LIBS_C_ASM := $(LIBS_C:.c=.asm)
LIBS_ASM := $(filter-out $(LIBS_C_ASM), $(wildcard lib/*.asm))
LIBS_SOURCES := $(sort $(LIBS_C_ASM) $(LIBS_ASM))

ALL_SOURCES := $(BIOS_SOURCES) $(LIBS_SOURCES)

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
