# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := input_test.asm
LIBS := ../lib/string.asm ../lib/clearscreen.asm ../lib/sprintf.asm ../lib/math.asm ../lib/heap.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/terminal_output.asm ../lib/terminal_input.asm ../lib/cursor.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: input_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

input_test.hex: ../assembler.py $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: input_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer write input_test.hex

