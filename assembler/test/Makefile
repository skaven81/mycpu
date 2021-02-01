# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := test.asm 
LIBS := ../lib/clearscreen.asm ../lib/strcpy.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@

