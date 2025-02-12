# vim: ts=4 sts=4 sw=4 noexpandtab

BIOS_SOURCES := 00-main.asm 10-shell_command.asm 20-cmd_*.asm
LIBS := $(wildcard lib/*.asm)
OPCODES := ../gen_opcodes.sh
MACROS := ../asm_macros
SHELL_COMMANDS := $(shell find . -mindepth 1 -maxdepth 1 -type d -exec test -e '{}/Makefile' \; -print)

all: os.hex $(SHELL_COMMANDS:%=%/all)

opcodes.out: $(OPCODES)
	bash -c "$(OPCODES) > $@"

os.hex os.sym: $(BIOS_SOURCES) $(LIBS) opcodes.out $(MACROS)
	../assembler.py -v --opcodes opcodes.out $(foreach asm_macro, $(MACROS), --macros $(asm_macro)) $(BIOS_SOURCES) $(LIBS) --output $@ --output-symbols $(@:.hex=.sym) 2>&1 | tee assembler.log

$(SHELL_COMMANDS:%=%/all): os.sym opcodes.out
	$(MAKE) -C $(@D)

program: os.hex
	~/serial-eeprom-programmer/programmer write os.hex

program1: os.hex
	~/serial-eeprom-programmer/programmer --port /dev/ttyUSB1 write os.hex

clean:
	rm -f os.hex os.sym opcodes.out
	@for dir in $(SHELL_COMMANDS); do \
		$(MAKE) -C $$dir clean; \
	done

