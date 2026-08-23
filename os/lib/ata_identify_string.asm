# vim: syntax=asm-mycpu

#####
# ata_identify_string - full verbose "model + firmware + capacity" ATA
# drive identity string
#
# Evicted from the BIOS ROM (was in os/bios/lib/ata.asm) because its only
# consumer, the boot-time ATA banner in os/bios/30-ata_init.asm, was
# rewritten to use the new, much smaller BIOS-resident :ata_boot_identify
# instead (see os/bios/lib/ata.asm). This full version is kept here for any
# future ODY program that wants the complete "${model}${fw_version}
# ${num_sectors>>11}MiB" description of a drive rather than just a
# present/not-detected check.
#
# Symlink this file (and ata_identify_string.h, if compiling from C) into
# any ODY build directory that needs it. It calls only BIOS-resident
# functions (:ata_identify, :calloc_blocks, :malloc_segments, :free,
# :shift16_b_right, :sprintf, :strcpy, plus the standard :heap_push_*/
# :heap_pop_* helpers), so it links fine wherever it is compiled in.
#####

# ata_identify_string - send the ID command to the drive and return
# a string describing the drive, or a string containing "Not detected\0"
# if the drive is not detected. For a detected drive, the string returned
# will be "${model}${fw_version} ${num_sectors>>11}MiB\0"
#  * logical sector size is at words 117..118 (DWord), optional, assume 512 bytes
#  * model is at words 27..46
#  * firmware is at words 23..26
#  * number of addressable sectors is at words 60-61 (DWord)
#
# To use this function:
#  1. push a byte onto the heap: 0=master, 1=slave drive
#  2. call the function
#  3. pop the string address (word) from the heap
#  4. print the string (or whatever)
#  5. free the string address (size 3, 64 bytes)
:ata_identify_string
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_AL                   # master/slave in AL
ALUOP_PUSH %A%+%AL%                 # store on stack for now

LDI_AL 4                            # 4 blocks, 64 bytes
CALL :calloc_blocks                 # address in A, this will be our output string
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # Copy destination address into D
CALL :heap_push_D                   # Put our return string on the heap

LDI_AL 4                            # 4 segments, 512 bytes
CALL :malloc_segments               # address in A, sector read buffer
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # Copy sector buffer address into C

CALL :heap_push_A                   # push sector buffer from A
POP_AL
CALL :heap_push_AL                  # push master/slave byte from AL

CALL :ata_identify
CALL :heap_pop_AL                   # status byte in AL
ALUOP_FLAGS %A%+%AL%
JNZ .not_detected

.detected                           # memory at C contains the identity sector
### model
MOV_CH_AH                           # copy sector addr into A
MOV_CL_AL
LDI_B 54                            # offset to word 27=byte 54/0x36 (model)
ALUOP16O_A %ALU16_A+B%                    # A points at first byte of model
# read 20 words (in little-endian format) into D
LDI_BL 20
.ata_identify_string_model_loop
ALUOP_PUSH %B%+%BL%
LDA_A_BL                            # first byte is low
ALUOP16O_A %ALU16_A+1%
LDA_A_BH                            # second byte is high
ALUOP16O_A %ALU16_A+1%

ALUOP_ADDR_D %B%+%BH%               # write high byte
INCR_D
ALUOP_ADDR_D %B%+%BL%               # write low byte
INCR_D
POP_BL
ALUOP_BL %B-1%+%BL%                 # decrement counter
JNZ .ata_identify_string_model_loop # continue until decrementing returns zero

### version
MOV_CH_AH                           # reset sector addr in A
MOV_CL_AL
LDI_B 46                            # offset to word 23=byte 46/0x2e (firmware)
ALUOP16O_A %ALU16_A+B%                    # A points at first byte of firmware

# read 4 words (in little-endian format) into D
LDI_BL 4
.ata_identify_string_vers_loop
ALUOP_PUSH %B%+%BL%
LDA_A_BL                            # first byte is low
ALUOP16O_A %ALU16_A+1%
LDA_A_BH                            # second byte is high
ALUOP16O_A %ALU16_A+1%

ALUOP_ADDR_D %B%+%BH%               # write high byte
INCR_D
ALUOP_ADDR_D %B%+%BL%               # write low byte
INCR_D
POP_BL
ALUOP_BL %B-1%+%BL%                 # decrement counter
JNZ .ata_identify_string_vers_loop  # continue until decrementing returns zero

### capacity
MOV_CH_AH                           # reset sector addr in A
MOV_CL_AL
LDI_B 120                           # offset to word 60=byte 120/0x78 (sectors)
ALUOP16O_A %ALU16_A+B%                    # A points at first byte of sector count
# read 2 words (in little-endian format) into A (high) and B (low)
ALUOP16O_A %ALU16_A+1%                      # ignore the first byte, as we are going
                                    # to shift 11 bits anyway
LDA_A_BL                            # second byte is now LSB
ALUOP16O_A %ALU16_A+1%
LDA_A_BH                            # third byte is MSB
ALUOP16O_A %ALU16_A+1%
CALL :shift16_b_right               # shift B right three places to get to 11
CALL :shift16_b_right
CALL :shift16_b_right
LDA_A_SLOW_PUSH                     # last byte now in AH, but unshifted
POP_AH
ALUOP_AH %A>>1%+%AH%
JNO .ata_identify_str_shift1
LDI_AL 0b00100000
ALUOP_BH %A|B%+%AL%+%BH%            # set third bit of BH if shift overflowed
.ata_identify_str_shift1
ALUOP_AH %A>>1%+%AH%
JNO .ata_identify_str_shift2
LDI_AL 0b01000000
ALUOP_BH %A|B%+%AL%+%BH%            # set second bit of BH if shift overflowed
.ata_identify_str_shift2
ALUOP_AH %A>>1%+%AH%
JNO .ata_identify_str_shift3
LDI_AL 0b10000000
ALUOP_BH %A|B%+%AL%+%BH%            # set first bit of BH if shift overflowed
.ata_identify_str_shift3
# B now contains the capacity in MiB
# sprintf the lowest word into D as 16-bit decimal number
PUSH_CH
PUSH_CL
LDI_C .num_conversion_str
CALL :heap_push_B
CALL :sprintf
POP_CL
POP_CH

# Clean up sector buffer
MOV_CH_AH                           # Put sector buffer addr into A
MOV_CL_AL
CALL :free                          # free the sector buffer

# done
JMP .ata_identify_string_done

.not_detected
MOV_CH_AH                           # Put sector buffer addr into A
MOV_CL_AL
CALL :free                          # free the sector buffer
LDI_C .not_detected_str             # string to return
CALL :strcpy                        # copy string from C to D
JMP .ata_identify_string_done

.ata_identify_string_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.not_detected_str "Not detected\0"
.num_conversion_str " %U MiB\0"
