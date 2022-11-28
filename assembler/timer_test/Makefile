# vim: ts=4 sts=4 sw=4 noexpandtab

SOURCES := timer_test.asm 
LIBS := ../lib/clearscreen.asm ../lib/strcpy.asm
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros

all: timer_test.hex

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

timer_test.hex: $(SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(SOURCES) $(LIBS) --output $@ >assembler.log 2>&1

program: timer_test.hex
	/raid/msp430/projects/serial-eeprom-programmer/programmer --verify write timer_test.hex

