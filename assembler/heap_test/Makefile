# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := heap_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/timer.asm ../lib/keyboard.asm ../lib/heap.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: heap_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

heap_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@

program: heap_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write heap_test.hex

