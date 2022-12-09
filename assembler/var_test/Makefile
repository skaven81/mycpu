# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := var_test.asm 
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: var_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

var_test.hex: $(SOURCES) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) --output $@

