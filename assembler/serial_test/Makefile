# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := serial_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/string.asm ../lib/uart.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/heap.asm ../lib/cursor.asm ../lib/terminal_output.asm ../lib/math.asm ../lib/sprintf.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: serial_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

serial_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: serial_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write serial_test.hex

