# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := color_test.asm 
LIBS := ../lib/clearscreen.asm 
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: color_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

color_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@

program: color_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write color_test.hex
