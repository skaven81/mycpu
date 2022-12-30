# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := keyboard_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/string.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: keyboard_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

keyboard_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ >assembler.log 2>&1

program: keyboard_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write keyboard_test.hex

