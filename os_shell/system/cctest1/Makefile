# vim: ts=4 sts=4 sw=4 noexpandtab

DIRNAME := $(notdir $(CURDIR))
FILENAME := $(shell echo $(DIRNAME) | tr '[:lower:]' '[:upper:]').ODY
MACROS := $(shell ls -1 ../../../assembler/asm_macros 2>/dev/null)
MEM_TARGET=main
LIBDIR := $(shell realpath ../../lib)

#C_SRC = $(wildcard *.c)
C_SRC = main.c
C_ASMS = $(C_SRC:.c=.asm)

# ensure `tee` pipe doesn't mask assembler failures
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

all: $(FILENAME)

%.asm: %.c
	../../../c_compiler/c_compiler.py $(VERBOSE_FLAG) --cpp-args='-I$(LIBDIR)' $< --output=$@

$(FILENAME): $(C_ASMS)  ../../os.sym ../../opcodes.out
	@[ $$(echo -n $(DIRNAME) | wc -c) -le 8 ] || ( echo "ERROR: command names cannot be more than 8 characters" && exit 1 )
	../../../assembler/assembler.py $(VERBOSE_FLAG) --opcodes ../../opcodes.out --symbols ../../os.sym $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) --odyssey --odyssey-target $(MEM_TARGET) --output $(FILENAME) $(C_ASMS) 2>&1 | tee assembler.log

.PHONY: sdcard
sdcard: $(FILENAME)
	@test -d $(INSTALL_DIRECTORY) || ( echo ERROR: $(INSTALL_DIRECTORY) does not exist && exit 1 )
	@mkdir -p $(INSTALL_DIRECTORY)/SYS
	@cp -v $(FILENAME) $(INSTALL_DIRECTORY)/SYS/$(FILENAME)

.PHONY: clean
clean:
	rm -f $(FILENAME)
	rm -f $(C_ASMS)
	rm -f assembler.log
