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
# jumps to a constant address for the IRQ vector.  Uses
# D register to transfer the address, as it can be incremented
# without the ALU.  So this opcode has an interleaved
# PUSH_D and POP_D as well.
cat <<EOF

[0xee] IRQ
# PC is still pointing at our return address, as
# the 0xee op was forced in instead of the intended
# next instruction.
x 0 MaskInterrupts IncrementSP
# Write PC to stack
x 1 AddrBusSP DataBusPCL WriteRAM IncrementSP
x 2 AddrBusSP DataBusPCH WriteRAM IncrementSP
# Save D register to stack
x 3 AddrBusSP DataBusDH WriteRAM IncrementSP
x 4 AddrBusSP DataBusDL WriteRAM
# Load IRQ vec constant to DH
x 5 DataBusIrqBase WriteDH
# Load IRQ ID (shifted left one) to DL
x 6 DataBusIrqId WriteDL
# Load RAM@D into PC
x 7 AddrBusD WritePCH
x 8 IncrementD
x 9 AddrBusD WritePCL
# Pop D from stack
x a AddrBusSP WriteDL DecrementSP
x b AddrBusSP WriteDH DecrementSP
# Execute referenced instruction
x c NextInstruction
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

# Load the status register into a register
opcode=$(hex_to_dec 06)
for to_reg in AL BL; do
offset=$((${#to_reg}-1))
cat <<EOF

[0x$(printf "%02x" $opcode)] STATUS_${to_reg}
x 0 IncrementPC DataBusStatus Write${to_reg}
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

# 16-bit store immediate.  This is a single-instruction implementation of:
# (3) PUSH_DL
# (3) PUSH_DH
# (6) ST @addr @data
# (5) ST @addr+1 @data+1
# (2) POP_DH
# (2) POP_DL
# So doing this in normal instructions would take 21 clocks, but we do it here in 11,
# and also cannot be interrupted during the operation.
cat <<EOF

[0x0e] ST16 @addr @data
x 0 IncrementPC IncrementSP
# PC now points at high byte of address
# Push D reg onto stack
x 1 AddrBusSP DataBusDL WriteRAM IncrementSP
x 2 AddrBusSP DataBusDH WriteRAM
x 3 AddrBusPC WriteDH IncrementPC
# PC now points at low byte of address
x 4 AddrBusPC WriteDL IncrementPC
# PC now points at high byte of data
x 5 AddrBusPC WriteTD IncrementPC
# PC now points at low byte of data
x 6 AddrBusD DataBusTD WriteRAM
x 7 AddrBusPC WriteTD IncrementD
x 8 AddrBusD DataBusTD WriteRAM IncrementPC
# PC now points at next instruction
# Pop D reg from stack
x 9 AddrBusSP WriteDH DecrementSP
x a AddrBusSP WriteDL DecrementSP
x b NextInstruction
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
for to_reg in ${WRITABLE_REGS[@]}; do
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
# Slow load/store operations, for interfacing with devices that
# require the address/data lines to be stable before and/or after
# the read or write operation occurs. These instructions spread
# out the read and write operations over multiple clock ticks
# to allow slow devices to work.  Note that the device is responsible
# for latching in the address and control signals, as they will
# still flap across sequence boundaries.
#
# There is a SEQ45 signal at (C)H22 that goes high during SEQ4
# and SEQ5 (with no glitch in between) which can be used to trigger
# device latching/writing behavior.
#
# Writing to the device
#  * SEQ4 - Latch the address and data
#  * SEQ5 - /WRAM is asserted
#  * SEQ6 - address and data remain asserted
#
# Reading from the device
#  * SEQ3 - Address bus is valid
#  * SEQ4 - Address bus is valid
#  * SEQ5 - Address bus is valid - data bus is written to register at end of clock cycle
#  * SEQ6 - Address bus is valid
####
opcode=$(hex_to_dec a0)
cat <<EOF

[0x$(printf "%02x" $opcode)] ST_SLOW @addr \$data
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to data byte
x 3 AddrBusPC WriteTD IncrementPC
x 4 AddrBusTA DataBusTD
x 5 AddrBusTA DataBusTD WriteRAM
x 6 AddrBusTA DataBusTD
x 7 NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP_ADDR_SLOW \$op @addr
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to high byte of target address
x 2 AddrBusPC WriteTAH IncrementPC
x 3 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 4 DataBusALU AddrBusTA WriteStatus
x 5 DataBusALU AddrBusTA WriteRAM
x 6 DataBusALU AddrBusTA
x 7 NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP_PUSH_SLOW \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 2 IncrementSP
x 3 DataBusALU AddrBusSP
x 4 DataBusALU AddrBusSP WriteStatus
x 5 DataBusALU AddrBusSP WriteRAM
x 6 DataBusALU AddrBusSP
x 7 NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] LD_SLOW_PUSH @addr
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 3 AddrBusTA
x 4 AddrBusTA
x 5 AddrBusTA WriteTD
x 6 AddrBusTA IncrementSP
x 7 AddrBusSP DataBusTD WriteRAM
x 8 NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] ST_SLOW_POP @addr
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to next instruction
x 3 AddrBusSP WriteTD
x 4 AddrBusTA DataBusTD DecrementSP
x 5 AddrBusTA DataBusTD WriteRAM
x 6 AddrBusTA DataBusTD
x 7 NextInstruction
EOF
let "opcode = opcode + 1"

for addr_reg in ${ADDR_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] LDA_${addr_reg}_SLOW_PUSH
x 0 IncrementPC
x 1 AddrBus${addr_reg}
x 2 AddrBus${addr_reg}
x 3 AddrBus${addr_reg}
x 4 AddrBus${addr_reg}
x 5 AddrBus${addr_reg} WriteTD
x 6 AddrBus${addr_reg} IncrementSP
x 7 AddrBusSP DataBusTD WriteRAM
x 8 NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] STA_${addr_reg}_SLOW_POP
x 0 IncrementPC
x 1 AddrBusSP
x 2 AddrBusSP
x 3 AddrBusSP WriteTD
x 4 AddrBus${addr_reg} DataBusTD DecrementSP
x 5 AddrBus${addr_reg} DataBusTD WriteRAM
x 6 AddrBus${addr_reg} DataBusTD
x 7 NextInstruction
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

# Load the IRQ base into a register
opcode=$(hex_to_dec d0)
for to_reg in ${WRITABLE_REGS[@]}; do
offset=$((${#to_reg}-1))
cat <<EOF

[0x$(printf "%02x" $opcode)] IRQBASE_${to_reg}
x 0 IncrementPC DataBusIrqBase Write${to_reg}
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Load the IRQ ID into a register
for to_reg in ${WRITABLE_REGS[@]}; do
offset=$((${#to_reg}-1))
cat <<EOF

[0x$(printf "%02x" $opcode)] IRQID_${to_reg}
x 0 IncrementPC DataBusIrqId Write${to_reg}
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Multi-value incr/decr for D register to support frame pointer manipulation
cat <<EOF

[0xe0] INCR4_D
x 0 IncrementPC IncrementD
x 1 IncrementD
x 2 IncrementD
x 3 IncrementD
x 4 NextInstruction

[0xe1] INCR8_D
x 0 IncrementPC IncrementD
x 1 IncrementD
x 2 IncrementD
x 3 IncrementD
x 4 IncrementD
x 5 IncrementD
x 6 IncrementD
x 7 IncrementD
x 8 NextInstruction

[0xe2] DECR4_D
x 0 IncrementPC DecrementD
x 1 DecrementD
x 2 DecrementD
x 3 DecrementD
x 4 NextInstruction

[0xe3] DECR8_D
x 0 IncrementPC DecrementD
x 1 DecrementD
x 2 DecrementD
x 3 DecrementD
x 4 DecrementD
x 5 DecrementD
x 6 DecrementD
x 7 DecrementD
x 8 NextInstruction

EOF

# 16-bit ALU operation: unconditional lo then hi
opcode=$(hex_to_dec e4)
for to_reg in A B; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP16_${to_reg} \$lo_op \$hi_op
x 0 IncrementPC
# PC now points to \$lo_op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op
x 2 DataBusALU Write${to_reg}L WriteStatus
x 3 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 4 DataBusALU Write${to_reg}H WriteStatus
x 5 NextInstruction
EOF
let "opcode = opcode + 1"
done

# 16-bit ALU operation: overflow flag
for to_reg in A B; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP16O_${to_reg} \$lo_op \$hi_op_o \$hi_op_no
x 0 IncrementPC
# PC now points to \$lo_op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_o
x 2 DataBusALU Write${to_reg}L WriteStatus
# overflow condition: stay at \$hi_op_o
O 3 AddrBusPC
O 4 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_no
O 5 DataBusALU Write${to_reg}H WriteStatus
# no-overflow condition: move to \$hi_op_no
o 3 IncrementPC
# PC now points to \$hi_op_no
o 4 AddrBusPC WriteALUop
# PC now points to next instruction
o 5 DataBusALU Write${to_reg}H WriteStatus
x 6 IncrementPC
# PC now points to next instruction
x 7 NextInstruction
EOF
let "opcode = opcode + 1"
done

# 16-bit ALU operation: equal flag
for to_reg in A B; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP16E_${to_reg} \$lo_op \$hi_op_eq \$hi_op_ne
x 0 IncrementPC
# PC now points to \$lo_op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_o
x 2 DataBusALU Write${to_reg}L WriteStatus
# overflow condition: stay at \$hi_op_o
E 3 AddrBusPC
E 4 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_no
E 5 DataBusALU Write${to_reg}H WriteStatus
# no-overflow condition: move to \$hi_op_no
e 3 IncrementPC
# PC now points to \$hi_op_no
e 4 AddrBusPC WriteALUop
# PC now points to next instruction
e 5 DataBusALU Write${to_reg}H WriteStatus
x 6 IncrementPC
# PC now points to next instruction
x 7 NextInstruction
EOF
let "opcode = opcode + 1"
done

# 16-bit ALU operation: zero flag
for to_reg in A B; do
cat <<EOF

[0x$(printf "%02x" $opcode)] ALUOP16Z_${to_reg} \$lo_op \$hi_op_z \$hi_op_nz
x 0 IncrementPC
# PC now points to \$lo_op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_o
x 2 DataBusALU Write${to_reg}L WriteStatus
# overflow condition: stay at \$hi_op_o
Z 3 AddrBusPC
Z 4 AddrBusPC WriteALUop IncrementPC
# PC now points to \$hi_op_no
Z 5 DataBusALU Write${to_reg}H WriteStatus
# no-overflow condition: move to \$hi_op_no
z 3 IncrementPC
# PC now points to \$hi_op_no
z 4 AddrBusPC WriteALUop
# PC now points to next instruction
z 5 DataBusALU Write${to_reg}H WriteStatus
x 6 IncrementPC
# PC now points to next instruction
x 7 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Load a whole word from RAM into A or B.  We can't do this into C or
# D because of limitations in the CDSEL control signal (can't put D
# on address bus and write CL/CH, or vice-versa).
opcode=$(hex_to_dec f0)
for to_reg in A B; do
cat <<EOF

[0x$(printf "%02x" $opcode)] LD16_${to_reg} @addr
x 0 IncrementPC IncrementSP
# Push D reg onto stack
x 1 AddrBusSP DataBusDL WriteRAM IncrementSP
x 2 AddrBusSP DataBusDH WriteRAM
# PC now points at high byte of address
x 3 AddrBusPC WriteDH IncrementPC
# PC now points at low byte of address
x 4 AddrBusPC WriteDL IncrementPC
# D now points at high byte of data
x 5 AddrBusD Write${to_reg}H
x 6 IncrementD
# D now points at low byte of data
x 7 AddrBusD Write${to_reg}L
# PC now points at next instruction
# Pop D reg from stack
x 8 AddrBusSP WriteDH DecrementSP
x 9 AddrBusSP WriteDL DecrementSP
x a NextInstruction
EOF
let "opcode = opcode + 1"
done

# Quickly (and atomically) copy data from an address
# in C to an address in D.  Both C and D are incremented after
# the operation.
cat <<EOF

[0x$(printf "%02x" $opcode)] MEMCPY_C_D
x 0 IncrementPC AddrBusC WriteTD
x 1 AddrBusD DataBusTD WriteRAM
x 2 IncrementC
x 3 IncrementD NextInstruction
EOF
let "opcode = opcode + 1"

# Same but copies four bytes at a time
cat <<EOF

[0x$(printf "%02x" $opcode)] MEMCPY4_C_D
x 0 IncrementPC AddrBusC WriteTD
x 1 AddrBusD DataBusTD WriteRAM
x 2 IncrementC
x 3 IncrementD
x 4 AddrBusC WriteTD
x 5 AddrBusD DataBusTD WriteRAM
x 6 IncrementC
x 7 IncrementD
x 8 AddrBusC WriteTD
x 9 AddrBusD DataBusTD WriteRAM
x a IncrementC
x b IncrementD
x c AddrBusC WriteTD
x d AddrBusD DataBusTD WriteRAM
x e IncrementC
x f IncrementD NextInstruction
EOF
let "opcode = opcode + 1"

# Quickly fill memory referenced at C, with a byte either
# in DL or on top of the stack or provided as an argument.
# C is incremented after the operation
cat <<EOF

[0x$(printf "%02x" $opcode)] MEMFILL4_C_DL
x 0 IncrementPC DataBusDL WriteTD
x 1 AddrBusC DataBusTD WriteRAM
x 2 IncrementC
x 3 AddrBusC DataBusTD WriteRAM
x 4 IncrementC
x 5 AddrBusC DataBusTD WriteRAM
x 6 IncrementC
x 7 AddrBusC DataBusTD WriteRAM
x 8 IncrementC NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] MEMFILL4_C_PEEK
x 0 IncrementPC AddrBusSP WriteTD
x 1 AddrBusC DataBusTD WriteRAM
x 2 IncrementC
x 3 AddrBusC DataBusTD WriteRAM
x 4 IncrementC
x 5 AddrBusC DataBusTD WriteRAM
x 6 IncrementC
x 7 AddrBusC DataBusTD WriteRAM
x 8 IncrementC NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] MEMFILL4_C_I \$byte
x 0 IncrementPC AddrBusPC WriteTD
x 1 IncrementPC AddrBusC DataBusTD WriteRAM
x 2 IncrementC
x 3 AddrBusC DataBusTD WriteRAM
x 4 IncrementC
x 5 AddrBusC DataBusTD WriteRAM
x 6 IncrementC
x 7 AddrBusC DataBusTD WriteRAM
x 8 IncrementC NextInstruction
EOF
let "opcode = opcode + 1"

cat <<EOF

[0x$(printf "%02x" $opcode)] CALL_D
x 0 IncrementPC IncrementSP
# PC now points to next instruction address;
# Write low byte to stack
x 1 AddrBusSP DataBusPCL WriteRAM IncrementSP
# Write high byte to stack
x 2 AddrBusSP DataBusPCH WriteRAM
# Load next instruction address from D
x 3 DataBusDH WritePCH
x 4 DataBusDL WritePCL
x 5 NextInstruction
EOF
let "opcode = opcode + 1"


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

