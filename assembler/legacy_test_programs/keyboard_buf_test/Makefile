# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := keyboard_buf_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/string.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: keyboard_buf_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

keyboard_buf_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ >assembler.log 2>&1

program: keyboard_buf_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write keyboard_buf_test.hex

