# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := sprintf_test.asm
LIBS := ../lib/clearscreen.asm ../lib/sprintf.asm ../lib/math.asm ../lib/heap.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/system.asm ../lib/string.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: sprintf_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

sprintf_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ 2>&1 | tee assembler.log

program: sprintf_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write sprintf_test.hex

