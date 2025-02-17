# vim: ts=4 sts=4 sw=4 noexpandtab

BIOS_SOURCES := 00-main.asm
LIBS := $(wildcard lib/*.asm)
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros
SHELL_COMMANDS := $(shell find . -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/Makefile' \; -print)

VERBOSE_quiet := 
VERBOSE_verbose := -v
VERBOSE_debug := -vv
VERBOSE ?= quiet
VERBOSE_FLAG=$(VERBOSE_$(VERBOSE))

INSTALL_DIRECTORY := /media/skaven/ODYSSEY
STAMPS_DIR := .stamps
$(shell mkdir -p $(STAMPS_DIR))

# ensure `tee` pipe doesn't mask assembler failures
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

all: os.hex $(SHELL_COMMANDS:%=%/all)

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

os.hex os.sym: $(BIOS_SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py $(VERBOSE_FLAG) --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(BIOS_SOURCES) $(LIBS) --output $@ --output-symbols $(@:.hex=.sym) 2>&1 | tee assembler.log

# Create targets like ascii/all and clock/all, etc. and make them depend
# on the symbol table and opcodes file. If these dependencies change, run
# `make all` inside the subdirs.
$(SHELL_COMMANDS:%=%/all): os.sym opcodes.out
	$(MAKE) -C $(@D) VERBOSE_FLAG=$(VERBOSE_FLAG)

# Call the `make sdcard` sub-targets, which themselves depend on building the .ODY file
.PHONY: sdcard
sdcard: $(SHELL_COMMANDS:%=%/sdcard)
$(SHELL_COMMANDS:%=%/sdcard): %/sdcard: %/all
	$(MAKE) -C $(@D) sdcard INSTALL_DIRECTORY=$(INSTALL_DIRECTORY)

# utility targets for programming the EEPROM
.PHONY: program program1
program: all
	~/serial-eeprom-programmer/programmer write os.hex
program1: all
	~/serial-eeprom-programmer/programmer --port /dev/ttyUSB1 write os.hex

# Cleanup routines
.PHONY: clean
clean: $(SHELL_COMMANDS:%=%/clean)
	rm -f os.hex os.sym opcodes.out
$(SHELL_COMMANDS:%=%/clean):
	$(MAKE) -C $(@D) clean

# Shortcuts so that I can run `make verbose` and everything gets built
# using verbose flags.  Note the VERBOSE macros at the top of the file
# that make this possible.
.PHONY: quiet verbose debug
quiet:
	$(MAKE) VERBOSE=quiet
verbose:
	$(MAKE) VERBOSE=verbose
debug:
	$(MAKE) VERBOSE=debug
