# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := cursor_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/timer.asm ../lib/cursor.asm ../lib/keyboard.asm ../lib/math.asm ../lib/heap.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: cursor_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

cursor_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: cursor_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write cursor_test.hex

