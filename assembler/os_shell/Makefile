# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := 00-main.asm 10-shell_command.asm
LIBS := ../lib/uart.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/clearscreen.asm ../lib/string.asm ../lib/heap.asm \
		../lib/cursor.asm ../lib/terminal_output.asm ../lib/math.asm ../lib/sprintf.asm ../lib/terminal_input.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: os.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

os.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: os.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write os.hex
