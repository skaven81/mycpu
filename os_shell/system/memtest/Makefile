# vim: ts=4 sts=4 sw=4 noexpandtab

DIRNAME := $(notdir $(CURDIR))
FILENAME := $(shell echo $(DIRNAME) | tr '[:lower:]' '[:upper:]').ODY
ASM_FILES := $(sort $(wildcard *.asm))
MACROS := $(shell ls -1 ../../../assembler/asm_macros 2>/dev/null)
MEM_TARGET=main

# ensure `tee` pipe doesn't mask assembler failures
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

all: $(FILENAME)

$(FILENAME): $(ASM_FILES) ../../os.sym ../../opcodes.out
	@[ $$(echo -n $(DIRNAME) | wc -c) -le 8 ] # command names cannot be more than 8 characters
	../../../assembler/assembler.py $(VERBOSE_FLAG) --opcodes ../../opcodes.out --symbols ../../os.sym $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) --odyssey --odyssey-target $(MEM_TARGET) --output $(FILENAME) $(ASM_FILES) 2>&1 | tee assembler.log

.PHONY: sdcard
sdcard: $(FILENAME)
	@test -d $(INSTALL_DIRECTORY) || ( echo ERROR: $(INSTALL_DIRECTORY) does not exist && exit 1 )
	@mkdir -p $(INSTALL_DIRECTORY)/SYS
	@cp -v $(FILENAME) $(INSTALL_DIRECTORY)/SYS/$(FILENAME)

.PHONY: clean
clean:
	rm -f $(FILENAME)
