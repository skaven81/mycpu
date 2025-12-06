# vim: ts=4 sts=4 sw=4 noexpandtab

DIRNAME := $(notdir $(CURDIR))
FILENAME := $(shell echo $(DIRNAME) | tr '[:lower:]' '[:upper:]').ODY
ASM_FILES := $(sort $(wildcard *.asm))
MACROS := $(shell ls -1 ../../assembler/asm_macros asm_macros 2>/dev/null)
SHELL_COMMANDS := $(shell find . -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/Makefile' \; -print)
MEM_TARGET=main

# ensure `tee` pipe doesn't mask assembler failures
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

.PHONY: all
all: $(FILENAME) $(SHELL_COMMANDS:%=%/all)

$(FILENAME): $(ASM_FILES) ../os.sym ../opcodes.out
	@[ $$(echo -n $(DIRNAME) | wc -c) -le 8 ] # command names cannot be more than 8 characters
	../../assembler/assembler.py $(VERBOSE_FLAG) --opcodes ../opcodes.out --symbols ../os.sym $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) --odyssey --odyssey-target $(MEM_TARGET) --output $(FILENAME) $(ASM_FILES) 2>&1 | tee assembler.log

$(SHELL_COMMANDS:%=%/all): ../os.sym ../opcodes.out
	$(MAKE) -C $(@D) VERBOSE_FLAG=$(VERBOSE_FLAG)

.PHONY: sdcard
sdcard: $(FILENAME) $(SHELL_COMMANDS:%=%/sdcard)
	@test -d $(INSTALL_DIRECTORY) || ( echo ERROR: $(INSTALL_DIRECTORY) does not exist && exit 1 )
	@mkdir -p $(INSTALL_DIRECTORY)
	@cp -v $(FILENAME) $(INSTALL_DIRECTORY)/$(FILENAME)

$(SHELL_COMMANDS:%=%/sdcard): ../os.sym ../opcodes.out
	@test -d $(INSTALL_DIRECTORY) || ( echo ERROR: $(INSTALL_DIRECTORY) does not exist && exit 1 )
	@mkdir -p $(INSTALL_DIRECTORY)
	$(MAKE) -C $(@D) sdcard INSTALL_DIRECTORY=$(INSTALL_DIRECTORY)

.PHONY: clean
clean: $(SHELL_COMMANDS:%=%/clean)
	rm -f $(FILENAME)
$(SHELL_COMMANDS:%=%/clean):
	$(MAKE) -C $(@D) clean

