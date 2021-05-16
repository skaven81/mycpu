# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := logic_test.asm 
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: logic_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

logic_test.hex: $(SOURCES) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) --output $@

