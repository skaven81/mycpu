# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := clockspeed_test.asm
LIBS := ../lib/clearscreen.asm ../lib/sprintf.asm ../lib/math.asm ../lib/heap.asm ../lib/keyboard.asm ../lib/timer.asm ../lib/system.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: clockspeed_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

clockspeed_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@

program: clockspeed_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer write clockspeed_test.hex

