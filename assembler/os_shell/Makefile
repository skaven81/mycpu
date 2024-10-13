# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := 00-main.asm 10-shell_command.asm 20-cmd_*.asm
LIBS := ../lib/uart.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/clearscreen.asm ../lib/string.asm ../lib/heap.asm \
		../lib/cursor.asm ../lib/terminal_output.asm ../lib/math.asm ../lib/sprintf.asm ../lib/terminal_input.asm \
		../lib/malloc.asm ../lib/memfill.asm ../lib/memcpy.asm ../lib/system.asm ../lib/strtoi.asm ../lib/ata.asm \
		../lib/extmalloc.asm ../lib/fat16_mount.asm ../lib/fat16_calc.asm ../lib/fat16_dirent.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: os.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

os.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: os.hex
	~/serial-eeprom-programmer/programmer write os.hex

program1: os.hex
	~/serial-eeprom-programmer/programmer --port /dev/ttyUSB1 write os.hex
