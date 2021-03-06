#!/bin/bash
# vim: syntax=sh ts=4 sts=4 sw=4 expandtab

PATH=/usr/bin:/usr/sbin:/bin:/sbin

# [opcode] NAME <arguments> - @arg = 16bit $arg = 8bit
#   opcode is the hexadecimal opcode, 0x00 - 0xff
#   NAME is the assembler name
#   arguments is a list of expected bytes after the opcode in the program,
#   @arg represents a 16-bit value (2 bytes), $arg represents an 8-bit
#   value (1 byte).
#
#   The microcode is written as a series of control sequences.  Each line
#   starts with one or two characters, (x,e,E,z,Z,o,O) that indicate that this
#   microcode entry should be executed for any flags (x), when the equal
#   flag is set (E) or clear (e), or the zero flag is set (Z) or clear (z),
#   or the overflow flag is set (O) or clear (o), or a combination (eZ, ZE),
#   etc.  A missing character means its value does not matter.  If neither
#   e nor z nor o matter, then "x" is a stand-in for "no status bits matter".
#
#   After this comes the sequence number,
#   from 0-f.  After this is a list of macros that will be
#   ORed to form the control signals for this microcode entry.

# General purpose registers that can be written to
WRITABLE_REGS=(AH AL BH BL CH CL DH DL)

# Registers that can only be used around instructions
# that don't use them internally.  These can read and
# write to the data bus.
VOLATILE_REGS=(TAL TD)

# General purpose registers that can be output to the data bus
DATA_REGS=(CH CL DH DL)

# General purpose registers that can be output to the address bus
ADDR_REGS=(A B C D)

# hex_to_dec $hex
# Outputs decimal digit
hex_to_dec ( ) {
    hex=$(echo $1 | tr 'a-f' 'A-F')
    echo "obase=10; ibase=16; $hex" | bc
}

# No-op: does nothing
cat <<EOF

[0x00] NOP
x 0 IncrementPC 
x 1 NextInstruction
EOF
let "opcode = opcode + 1"

# Call subroutine: push next instruction address onto
# the stack, then jump to the given address
cat <<EOF

[0x01] CALL @addr
x 0 IncrementPC
# PC now points to high byte of subroutine address;
# Write high byte to TAL (TAL can present to data bus)
x 1 AddrBusPC WriteTAL IncrementPC
# PC now points to low byte of subroute address;
# Write low byte to TD
x 2 AddrBusPC WriteTD IncrementPC IncrementSP
# PC now points to next instruction address;
# Write low byte to stack
x 3 AddrBusSP DataBusPCL WriteRAM IncrementSP
# Write high byte to stack
x 4 AddrBusSP DataBusPCH WriteRAM
# Load next instruction address from TAL & TD
x 5 DataBusTAL WritePCH
x 6 DataBusTD WritePCL
x 7 NextInstruction
EOF

# Return from subroutine: pop the next instruction
# address from the stack, jump to that address
cat <<EOF

[0x02] RET
x 0 AddrBusSP WritePCH DecrementSP
x 1 AddrBusSP WritePCL DecrementSP
x 2 NextInstruction
EOF

# IRQ operation -- like CALL, but masks interrupts, and
# jumps to a constant address for the IRQ vector
cat <<EOF

[0xee] IRQ
# PC is still pointing at our return address, as
# the 0xee op was forced in instead of the intended
# next instruction.
x 0 MaskInterrupts IncrementSP
# Write low byte of PC to stack
x 1 AddrBusSP DataBusPCL WriteRAM IncrementSP
# Write high byte of PC to stack
x 2 AddrBusSP DataBusPCH WriteRAM
# Load next instruction from constants
x 3 DataBusZero WritePCL
x 4 DataBusIRQ WritePCH
# Jump to the IRQ vector
x 5 NextInstruction
EOF

# IRQ return -- like RET, but unmasks interrupts.  Also
# restores the status flags from the backup preserved
# while interrupts are unmasked.
cat <<EOF

[0x03] RETI
x 0 AddrBusSP WritePCH DecrementSP UnmaskInterrupts
x 1 AddrBusSP WritePCL DecrementSP RestoreStatusFlags WriteStatus
x 2 NextInstruction
EOF

# Explicitly mask/unmask interrupts
cat <<EOF

[0x04] MASKINT
x 0 IncrementPC MaskInterrupts
x 1 NextInstruction

[0x05] UMASKINT
x 0 IncrementPC UnmaskInterrupts
x 1 NextInstruction
EOF

# Load the peripheral address into register D
opcode=$(hex_to_dec 6)
for to_reg in ${WRITABLE_REGS[@]}; do
offset=$((${#to_reg}-1))
[ "${to_reg:$offset:1}" = "L" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] PERIPH_${to_reg}
x 0 IncrementPC DataBusPeripheral Write${to_reg}
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Increment/decrement C and D
cat <<EOF

[0x0a] INCR_C
x 0 IncrementPC IncrementC
x 1 NextInstruction

[0x0b] DECR_C
x 0 IncrementPC DecrementC
x 1 NextInstruction

[0x0c] INCR_D
x 0 IncrementPC IncrementD
x 1 NextInstruction

[0x0d] DECR_D
x 0 IncrementPC DecrementD
x 1 NextInstruction
EOF

# Leave reserved instructions at the top of the range
opcode=$(hex_to_dec 10)

# Store to RAM: store the specified byte at
# the given address.
cat <<EOF

[0x$(printf "%02x" $opcode)] ST @addr \$data
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to data byte
x 3 AddrBusPC WriteTD IncrementPC
x 4 AddrBusTA DataBusTD WriteRAM
x 5 NextInstruction
EOF
let "opcode = opcode + 1"

# Store to RAM at an immediate address, from a general-purpose register
for from_reg in ${DATA_REGS[@]} ${VOLATILE_REGS[@]}; do
[ "${from_reg}" = "TAL" ] && continue
[ "${from_reg}" = "TAH" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] ST_${from_reg} @addr
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 3 AddrBusTA DataBus${from_reg} WriteRAM
x 4 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Load from RAM at an immediate address, to a general-purpose register
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
[ "${to_reg}" = "TAH" ] && continue
[ "${to_reg}" = "TAL" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] LD_${to_reg} @addr
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 3 AddrBusTA Write${to_reg}
x 4 NextInstruction
EOF
let "opcode = opcode + 1"
done

####
# Jumps: 0x20 - 0x2f
####

# Jump: unconditional jump to specified address
cat <<EOF

[0x20] JMP @addr
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
x 2 AddrBusPC WritePCL
x 3 DataBusTD WritePCH
x 4 NextInstruction
EOF

# Jump if equal: jump to address if equal flag is set
cat <<EOF

[0x21] JEQ @addr
x 0 IncrementPC
e 1 IncrementPC # skip over high @addr byte
e 2 IncrementPC # skip over low @addr byte
e 3 NextInstruction
# PC now points to high byte of target address
E 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
E 2 AddrBusPC WritePCL
E 3 DataBusTD WritePCH
E 4 NextInstruction
EOF

# Jump if not equal: jump to address if equal flag is unset
cat <<EOF

[0x22] JNE @addr
x 0 IncrementPC
E 1 IncrementPC # skip over high @addr byte
E 2 IncrementPC # skip over low @addr byte
E 3 NextInstruction
# PC now points to high byte of target address
e 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
e 2 AddrBusPC WritePCL
e 3 DataBusTD WritePCH
e 4 NextInstruction
EOF

# Jump if zero: jump to address if zero flag is set
cat <<EOF

[0x23] JZ @addr
x 0 IncrementPC
z 1 IncrementPC # skip over high @addr byte
z 2 IncrementPC # skip over low @addr byte
z 3 NextInstruction
# PC now points to high byte of target address
Z 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
Z 2 AddrBusPC WritePCL
Z 3 DataBusTD WritePCH
Z 4 NextInstruction
EOF

# Jump if not zero: jump to address if zero flag is unset
cat <<EOF

[0x24] JNZ @addr
x 0 IncrementPC
Z 1 IncrementPC # skip over high @addr byte
Z 2 IncrementPC # skip over low @addr byte
Z 3 NextInstruction
# PC now points to high byte of target address
z 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
z 2 AddrBusPC WritePCL
z 3 DataBusTD WritePCH
z 4 NextInstruction
EOF

# Jump if overflow: jump to address if overflow flag is set
cat <<EOF

[0x25] JO @addr
x 0 IncrementPC
o 1 IncrementPC # skip over high @addr byte
o 2 IncrementPC # skip over low @addr byte
o 3 NextInstruction
# PC now points to high byte of target address
O 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
O 2 AddrBusPC WritePCL
O 3 DataBusTD WritePCH
O 4 NextInstruction
EOF

# Jump if not overflow: jump to address if overflow flag is unset
cat <<EOF

[0x26] JNO @addr
x 0 IncrementPC
O 1 IncrementPC # skip over high @addr byte
O 2 IncrementPC # skip over low @addr byte
O 3 NextInstruction
# PC now points to high byte of target address
o 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
o 2 AddrBusPC WritePCL
o 3 DataBusTD WritePCH
o 4 NextInstruction
EOF

# Jump: unconditional jump to address in D
cat <<EOF

[0x27] JMP_D
x 0 IncrementPC
# PC now points to next instruction
x 1 DataBusDH WritePCH
x 2 DataBusDL WritePCL
x 3 NextInstruction
EOF

# Jump to addr in D if equal
cat <<EOF

[0x28] JEQ_D
x 0 IncrementPC
e 1 NextInstruction
E 1 DataBusDH WritePCH
E 2 DataBusDL WritePCL
E 3 NextInstruction
EOF

# Jump to addr in D if not equal
cat <<EOF

[0x29] JNE_D
x 0 IncrementPC
E 1 NextInstruction
e 1 DataBusDH WritePCH
e 2 DataBusDL WritePCL
e 3 NextInstruction
EOF

# Jump to addr in D if zero
cat <<EOF

[0x2a] JZ_D
x 0 IncrementPC
z 1 NextInstruction
Z 1 DataBusDH WritePCH
Z 2 DataBusDL WritePCL
Z 3 NextInstruction
EOF

# Jump to addr in D if not zero
cat <<EOF

[0x2b] JNZ_D
x 0 IncrementPC
Z 1 NextInstruction
z 1 DataBusDH WritePCH
z 2 DataBusDL WritePCL
z 3 NextInstruction
EOF

# Jump to addr in D if overflow
cat <<EOF

[0x2c] JO_D
x 0 IncrementPC
o 1 NextInstruction
O 1 DataBusDH WritePCH
O 2 DataBusDL WritePCL
O 3 NextInstruction
EOF

# Jump to addr in D if not overflow
cat <<EOF

[0x2d] JNO_D
x 0 IncrementPC
O 1 NextInstruction
o 1 DataBusDH WritePCH
o 2 DataBusDL WritePCL
o 3 NextInstruction
EOF

####
# Stack operations: 0x30...
####

# Push: put a static value on the stack
cat <<EOF

[0x30] PUSH \$data
x 0 IncrementPC IncrementSP
# PC now points to data; SP points to target address
x 1 AddrBusPC WriteTD
# TD now contains the data to be written to the stack
x 2 AddrBusSP DataBusTD WriteRAM IncrementPC
# PC now points to next instruction
x 3 NextInstruction
EOF

# Push a general purpose register onto the stack
opcode=$(hex_to_dec 31)
for from_reg in ${DATA_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] PUSH_${from_reg}
x 0 IncrementPC IncrementSP
# PC now points to next instruction; SP points to target address
x 1 AddrBusSP DataBus${from_reg} WriteRAM
x 2 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Peek: fetch the data from the top of the stack
# into a general purpose register, but don't remove it
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] PEEK_${to_reg}
x 0 AddrBusSP Write${to_reg} IncrementPC
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Pop: pop the top item on the stack into a
# general purpose register
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] POP_${to_reg}
x 0 AddrBusSP Write${to_reg} DecrementSP IncrementPC
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

####
# Load immediate value into a general purpose register
####

opcode=$(hex_to_dec 50)
# Store immediate word into 16-bit register
for to_reg in ${ADDR_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] LDI_${to_reg} @word
x 0 IncrementPC
x 1 AddrBusPC Write${to_reg}H IncrementPC
x 2 AddrBusPC Write${to_reg}L IncrementPC
x 3 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Store immediate byte into 8-bit register
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] LDI_${to_reg} \$byte
x 0 IncrementPC
x 1 AddrBusPC Write${to_reg} IncrementPC
x 2 NextInstruction
EOF
let "opcode = opcode + 1"
done

####
# Load/Store from/to RAM using the address in a 16-bit register,
# into a general purpose register
####

# Load from RAM@reg into reg
for addr_reg in ${ADDR_REGS[@]}; do
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
# Skip instructions where we are writing our own address
[ "${to_reg:0:-1}" = "${addr_reg}" ] && continue
# Skip instructions where we are reading and writing
# simultaneously to C/D registers since that's a single
# control signal
[ "${to_reg:0:-1}" = "C" ] && [ "${addr_reg}" = "D" ] && continue
[ "${to_reg:0:-1}" = "D" ] && [ "${addr_reg}" = "C" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] LDA_${addr_reg}_${to_reg}
x 0 IncrementPC AddrBus${addr_reg} Write${to_reg}
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done
done

# Store to RAM@reg from reg -- fast for A and B
for addr_reg in A B; do
for from_reg in ${DATA_REGS[@]} ${VOLATILE_REGS[@]}; do
# Skip instructions where we are writing our own address
[ "${from_reg:0:-1}" = "${addr_reg}" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] STA_${addr_reg}_${from_reg}
x 0 IncrementPC AddrBus${addr_reg} DataBus${from_reg} WriteRAM
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done
done

# Store to RAM@reg from reg -- slower for C and D
# since you can't simultaneously read and write
# the C and D registers
for addr_reg in C D; do
for from_reg in ${DATA_REGS[@]} ${VOLATILE_REGS[@]}; do
# Skip instructions where we are writing our own address
[ "${from_reg:0:-1}" = "${addr_reg}" ] && continue
[ "${from_reg:0:2}" = "TA" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] STA_${addr_reg}_${from_reg}
x 0 IncrementPC DataBus${addr_reg}H WriteTAH
x 1 DataBus${addr_reg}L WriteTAL
x 2 AddrBusTA DataBus${from_reg} WriteRAM
x 3 NextInstruction
EOF
let "opcode = opcode + 1"
done
done

####
# ALU operations: 0x90 - 0x9f
####

### ALU operations have the following format for $op
### bits 4-0 (mask 0x1f) = 5-bit opcode
### bit  5   (mask 0x20) = carry-in bit
### bit  6   (mask 0x40) = A bus hi(1)/lo(0)
### bit  7   (mask 0x80) = B bus hi(1)/lo(0)

# set flags only (do not store result)

# We have to enable the ALU's outputs to get
# the flags to appear.  We don't write anything
# to a register, but DataBusALU has to be asserted
# so that the ALU ROMs have their /OE pins set,
# otherwise the Z/O/E/Cout outputs just float
# on the data bus.
cat <<EOF

[0x90] ALUOP_FLAGS \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 2 DataBusALU WriteStatus
x 3 NextInstruction
EOF

# push ALU result onto stack
cat <<EOF

[0x91] ALUOP_PUSH \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC IncrementSP
# PC now points to next instruction
x 2 DataBusALU AddrBusSP WriteRAM WriteStatus
x 3 NextInstruction
EOF

# store ALU result in RAM at immediate address
cat <<EOF

[0x92] ALUOP_ADDR \$op @addr
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to high byte of target address
x 2 AddrBusPC WriteTAH IncrementPC
x 3 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 4 DataBusALU AddrBusTA WriteRAM WriteStatus
x 5 NextInstruction
EOF

opcode=$(hex_to_dec 93)

# store ALU result in RAM at an address register
for addr_reg in ${ADDR_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP_ADDR_${addr_reg} \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 2 DataBusALU AddrBus${addr_reg} WriteRAM WriteStatus
x 3 NextInstruction
EOF
let "opcode = opcode + 1"

done

# store ALU result in a general purpose register
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP_${to_reg} \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 2 DataBusALU Write${to_reg} WriteStatus
x 3 NextInstruction
EOF
let "opcode = opcode + 1"

done

####
# Transfer operations
####
opcode=$(hex_to_dec b0)

for from_reg in ${DATA_REGS[@]}; do
for to_reg in ${WRITABLE_REGS[@]} ${VOLATILE_REGS[@]}; do
[ "${from_reg}" = "${to_reg}" ] && continue
# Skip instructions where we are reading and writing
# simultaneously to C/D registers since that's a single
# control signal
[ "${from_reg:0:-1}" = "C" ] && [ "${to_reg:0:-1}" = "C" ] && continue
[ "${from_reg:0:-1}" = "C" ] && [ "${to_reg:0:-1}" = "D" ] && continue
[ "${from_reg:0:-1}" = "D" ] && [ "${to_reg:0:-1}" = "C" ] && continue
[ "${from_reg:0:-1}" = "D" ] && [ "${to_reg:0:-1}" = "D" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] MOV_${from_reg}_${to_reg}
x 0 IncrementPC DataBus${from_reg} Write${to_reg}
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
[ $opcode -eq 238 ] && opcode=239 # skip opcode 0xee as it's reserved for the IRQ op
done
done

# Halt: goes into infinite loop of loading the program
# counter address into the opcode register, but never
# incrementing the program counter.  So the CPU just
# runs HLT in an endless loop.  This is opcode 0xff
# because that's the default state of the data bus, so
# if a NextInstruction operation happens with the bus
# quiesced, the CPU just halts.
cat <<EOF

[0xff] HLT
x 0 NextInstruction
EOF

