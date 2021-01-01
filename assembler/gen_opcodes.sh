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
WRITABLE_REGS=(TAH TAL TD AH AL BH BL CH CL DH DL)

# General purpose registers that can be output to the data bus
DATA_REGS=(TAL TD CH CL DH DL)

# General purpose registers that can be output to the address bus
ADDR_REGS=(TA A B C D)

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

# Halt: goes into infinite loop of loading the program
# counter address into the opcode register, but never
# incrementing the program counter.  So the CPU just
# runs HLT in an endless loop.
cat <<EOF

[0xff] HLT
x 0 NextInstruction
EOF

####
# Load/store to RAM: 0x10 - 0x2f
####

# Store to RAM: store the specified byte at
# the given address.
cat <<EOF

[0x10] ST @addr $data
x 0 IncrementPC
# PC now points to high byte of target address
x 1 AddrBusPC WriteTAH IncrementPC
x 2 AddrBusPC WriteTAL IncrementPC
# PC now points to data byte
x 3 AddrBusPC WriteTD IncrementPC
x 4 AddrBusTA DataBusTD WriteRAM
x 5 NextInstruction
EOF

# Store to RAM at an immediate address, from a general-purpose register
opcode=$(hex_to_dec 11)
for from_reg in ${DATA_REGS[@]}; do
[ "${from_reg}" = "TAL" ] && continue
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
for to_reg in ${WRITABLE_REGS[@]}; do
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
# Jumps: 0x30 - 0x3f
####

# Jump: unconditional jump to specified address
cat <<EOF

[0x30] JMP @addr
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

[0x31] JEQ @addr
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

[0x32] JNE @addr
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

[0x33] JZ @addr
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

[0x34] JNZ @addr
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

[0x35] JO @addr
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

[0x36] JNO @addr
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

# Jump if equal and not overflow: jump to address if equal flag is set and overflow flag is unset
cat <<EOF

[0x37] JEQ_SAFE @addr
x 0 IncrementPC
e 1 IncrementPC # skip over high @addr byte
e 2 IncrementPC # skip over low @addr byte
e 3 NextInstruction
# PC now points to high byte of target address
Eo 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
Eo 2 AddrBusPC WritePCL
Eo 3 DataBusTD WritePCH
Eo 4 NextInstruction
EOF

# Jump if not equal and not overflow: jump to address if equal flag is unset and overflow flag is unset
cat <<EOF

[0x38] JNE_SAFE @addr
x 0 IncrementPC
E 1 IncrementPC # skip over high @addr byte
E 2 IncrementPC # skip over low @addr byte
E 3 NextInstruction
# PC now points to high byte of target address
eo 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
eo 2 AddrBusPC WritePCL
eo 3 DataBusTD WritePCH
eo 4 NextInstruction
EOF

# Jump if zero and not overflow: jump to address if zero flag is set and overflow flag is unset
cat <<EOF

[0x39] JZ_SAFE @addr
x 0 IncrementPC
z 1 IncrementPC # skip over high @addr byte
z 2 IncrementPC # skip over low @addr byte
z 3 NextInstruction
# PC now points to high byte of target address
Zo 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
Zo 2 AddrBusPC WritePCL
Zo 3 DataBusTD WritePCH
Zo 4 NextInstruction
EOF

# Jump if not zero and not overflow: jump to address if zero flag is unset and overflow flag is unset
cat <<EOF

[0x3a] JNZ_SAFE @addr
x 0 IncrementPC
Z 1 IncrementPC # skip over high @addr byte
Z 2 IncrementPC # skip over low @addr byte
Z 3 NextInstruction
# PC now points to high byte of target address
zo 1 AddrBusPC WriteTD IncrementPC
# TD now contains high byte of target address and
# PC points to low byte of target address
zo 2 AddrBusPC WritePCL
zo 3 DataBusTD WritePCH
zo 4 NextInstruction
EOF

####
# Stack operations: 0x40 - 0x5f
####

# Push: put a static value on the stack
cat <<EOF

[0x40] PUSH \$data
x 0 IncrementPC IncrementSP
# PC now points to data; SP points to target address
x 1 AddrBusPC WriteTD
# TD now contains the data to be written to the stack
x 2 AddrBusSP DataBusTD WriteRAM IncrementPC
# PC now points to next instruction
x 3 NextInstruction
EOF

# Push a general purpose register onto the stack
opcode=$(hex_to_dec 41)
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
for to_reg in ${WRITABLE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] PEEK_${to_reg}
x 0 AddrBusSP Write${to_reg} IncrementPC
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

# Pop: pop the top item on the stack into a
# general purpose register
for to_reg in ${WRITABLE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] POP_${to_reg}
x 0 AddrBusSP Write${to_reg} DecrementSP IncrementPC
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done

####
# Subroutine operations: 0x60 - 0x6f
####

# Call subroutine: push next instruction address onto
# the stack, then jump to the given address
cat <<EOF

[0x60] CALL @addr
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

[0x6f] RET
x 0 AddrBusSP WritePCH DecrementSP
x 1 AddrBusSP WritePCL DecrementSP
x 2 NextInstruction
EOF

####
# Load immediate value into a general purpose register
# 0x70 - 0x7f
####

opcode=$(hex_to_dec 70)

# Store immediate word into 16-bit register
for to_reg in ${ADDR_REGS[@]}; do
[ "${to_reg}" = "TA" ] && continue
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
for to_reg in ${WRITABLE_REGS[@]}; do
cat <<EOF

[0x$(printf "%02x" $opcode)] LDI_${to_reg} \$byte
x 0 IncrementPC
x 1 AddrBusPC Write${to_reg} IncrementPC
x 2 NextInstruction
EOF
let "opcode = opcode + 1"
done

####
# Load from RAM using the address in a 16-bit register,
# into a general purpose register: 0x80 - 0x9f
####

opcode=$(hex_to_dec 80)

# Load from RAM@reg into reg
for addr_reg in ${ADDR_REGS[@]}; do
for to_reg in ${WRITABLE_REGS[@]}; do
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

####
# Store to RAM using the address in a 16-bit register,
# from a general purpose register: 0x90 - 0xaf
####

opcode=$(hex_to_dec 90)

# Store to RAM@reg from reg
for addr_reg in ${ADDR_REGS[@]}; do
for from_reg in ${DATA_REGS[@]}; do
# Skip instructions where we are writing our own address
[ "${from_reg:0:-1}" = "${addr_reg}" ] && continue
# Skip instructions where we are reading and writing
# simultaneously to C/D registers since that's a single
# control signal
[ "${from_reg:0:-1}" = "C" ] && [ "${addr_reg}" = "D" ] && continue
[ "${from_reg:0:-1}" = "D" ] && [ "${addr_reg}" = "C" ] && continue
cat <<EOF

[0x$(printf "%02x" $opcode)] STA_${addr_reg}_${from_reg}
x 0 IncrementPC AddrBus${addr_reg} DataBus${from_reg} WriteRAM
x 1 NextInstruction
EOF
let "opcode = opcode + 1"
done
done

####
# ALU operations: 0xb0 - 0xcf
####

### ALU operations have the following format for $op
### bits 4-0 (mask 0x1f) = 5-bit opcode
### bit  5   (mask 0x20) = carry-in bit
### bit  6   (mask 0x40) = A bus hi(1)/lo(0)
### bit  7   (mask 0x80) = B bus hi(1)/lo(0)

# set flags only (do not store result)
cat <<EOF

[0xb0] ALUOP_FLAGS \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC
# PC now points to next instruction
x 2 WriteStatus NextInstruction
EOF

# push ALU result onto stack
cat <<EOF

[0xb2] ALUOP_PUSH \$op
x 0 IncrementPC
# PC now points to \$op
x 1 AddrBusPC WriteALUop IncrementPC IncrementSP
# PC now points to next instruction
x 2 DataBusALU AddrBusSP WriteRAM WriteStatus
x 3 NextInstruction
EOF

# store ALU result in RAM at immediate address
cat <<EOF

[0xb1] ALUOP_ADDR \$op @addr
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

# store ALU result in RAM at an addres register
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
opcode=$(hex_to_dec b3)
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


