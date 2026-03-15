# vim: syntax=asm-mycpu

# ATA port functions
# https://blog.retroleum.co.uk/electronics-articles/an-8-bit-ide-interface/

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

# ata_identify - send the ID command to the drive and return
# a 512-byte data frame containing the response. To use this
# function:
#  1. push the address (word) of a 512-byte memory segment onto the heap
#  2. push a byte onto the heap: 0=master, 1=slave drive
#  3. call the function
#  4. pop status byte from heap. This is just a copy of the %ata_err%
#     ATA register. If zero, the command was successful.  If non-zero,
#     the bits will correspond to the %ata_err% flags.
:ata_identify
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Pop the master/slave byte from the heap into AL
# and set the %ata_lba3% register to the requested drive
CALL :heap_pop_AL                   # master/slave in AL
ALUOP_FLAGS %A%+%AL%
JZ .ata_id_master
ST_SLOW %ata_lba3% %ata_lba3_slave%
JMP .ata_id_1
.ata_id_master
ST_SLOW %ata_lba3% %ata_lba3_master%
.ata_id_1

# Pop the address we'll be writing to, into C
CALL :heap_pop_C

# Gate on drive responsiveness with 1-second watchdog timeout before
# committing to the identify operation.
CALL :ata_drive_responsive          # AL = drive ID
JNZ .ata_id_timeout                 # if not responsive, abort

# Wait for the newly selected drive to become ready - returns
# status via the ALU zero flag
CALL .ata_wait_ready
JNZ .ata_id_timeout                 # If timeout, abort

# Send the drive ID command
ST_SLOW %ata_cmd_stat% %ata_cmd_identify%

# Wait for data request to be ready
CALL .ata_wait_data_request_ready

# Check for errors
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_err%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .ata_id_abort

# Read 256 words into address at C
CALL .ata_read_sector
LDI_AL 0x00 # no errors
CALL :heap_push_AL
JMP .ata_id_done

.ata_id_timeout
LDI_AL 0xff
CALL :heap_push_AL
JMP .ata_id_done

.ata_id_abort
LD_SLOW_PUSH %ata_err%
POP_AL
CALL :heap_push_AL

.ata_id_done
POP_CL
POP_CH
POP_BL
POP_AL
RET

########
# :ata_read_lba - given a 28-bit LBA address, load the sector
# at that address and read a 512-byte data frame into a target
# address.  To use this function:
#  1. push the address (word) of a 512-byte memory segment onto the heap
#  2. push the high word of the LBA address (bits 27-16) onto the heap
#  3. push the low word of the LBA address (bits 15-0) onto the heap
#  4. push a byte onto the heap to indicate which drive (0=master, 1=slave)
#  5. call the function
#  6. pop status byte from heap. This is just a copy of the %ata_err%
#     ATA register. If zero, the command was successful.  If non-zero,
#     the bits will correspond to the %ata_err% flags. If 0xff, the
#     requested drive did not respond at all and may not be attached.
:ata_read_lba
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CL
PUSH_CH

# Pops the master/slave byte and the two LBA address words
# from the heap and sets them on the ATA bus
CALL .ata_set_lba_address

# Wait for the newly selected drive to become ready - returns
# status via the ALU zero flag
CALL .ata_wait_ready
JNZ .ata_read_timeout               # If timeout, abort

# Put the destination address into C
CALL :heap_pop_C

# Set the number of sectors to read (1, 512 bytes)
ST_SLOW %ata_numsec% 0x01

# Send the command to the drive
ST_SLOW %ata_cmd_stat% %ata_cmd_read_retry%

# Wait for data request to be ready
CALL .ata_wait_data_request_ready

# Check for errors
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_err%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_read_begin                  # if no errors, begin reading bytes
LD_SLOW_PUSH %ata_err%              # else load errors
POP_AL
CALL :heap_push_AL
JMP .ata_read_done

# Read 256 words into address at C
.ata_read_begin
CALL .ata_read_sector
LDI_AL 0x00 # no errors
CALL :heap_push_AL
JMP .ata_read_done

# timeout vector
.ata_read_timeout
CALL :heap_pop_A                    # pop the destination address
LDI_AL 0xff
CALL :heap_push_AL
JMP .ata_read_done

.ata_read_done
POP_CH
POP_CL
POP_BL
POP_AL
RET

########
# :ata_write_lba - given a 28-bit LBA address, write the sector
# at that address from a 512-byte memory address.  To use this function:
#  1. push the address (word) of the 512-byte memory segment onto the heap
#  2. push the high word of the LBA address (bits 27-16) onto the heap
#  3. push the low word of the LBA address (bits 15-0) onto the heap
#  4. push a byte onto the heap to indicate which drive (0=master, 1=slave)
#  5. call the function
#  6. pop status byte from heap. This is just a copy of the %ata_err%
#     ATA register. If zero, the command was successful.  If non-zero,
#     the bits will correspond to the %ata_err% flags. If 0xff, the
#     requested drive did not respond at all and may not be attached.
:ata_write_lba
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CL
PUSH_CH

# Pops the master/slave byte and the two LBA address words
# from the heap and sets them on the ATA bus
CALL .ata_set_lba_address

# Wait for the newly selected drive to become ready - returns
# status via the ALU zero flag
CALL .ata_wait_ready
JNZ .ata_write_timeout              # If timeout, abort

# Put the source address into C
CALL :heap_pop_C

# Set the number of sectors to write (1, 512 bytes)
ST_SLOW %ata_numsec% 0x01

# Send the command to the drive
ST_SLOW %ata_cmd_stat% %ata_cmd_write_retry%

# Wait for data request to be ready
CALL .ata_wait_data_request_ready

# Write 256 words from address at C
CALL .ata_write_sector

# Wait for drive to become ready again
CALL .ata_wait_ready
JNZ .ata_write_timeout              # If timeout, abort

LDI_AL 0x00 # no errors
CALL :heap_push_AL
JMP .ata_write_done

# Check for errors
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_err%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_write_done_noerrors         # if no errors, load zero into AL to return

LD_SLOW_PUSH %ata_err%              # else load errors into AL to return
POP_AL
CALL :heap_push_AL
JMP .ata_write_done

.ata_write_done_noerrors
LDI_AL 0x00
CALL :heap_push_AL
JMP .ata_write_done

# timeout vector
.ata_write_timeout
CALL :heap_pop_A                    # pop the destination address
LDI_AL 0xff
CALL :heap_push_AL
JMP .ata_write_done

.ata_write_done
POP_CH
POP_CL
POP_BL
POP_AL
RET


########
# .ata_wait_ready
# Wait for the drive to become ready. Uses BH as a software
# countdown counter (~255 iterations, several ms at 2.2MHz),
# which is more than sufficient for a responding drive. A hardware
# watchdog timer is not needed here: drives that are present and
# spinning become ready in well under 1ms. The hardware watchdog
# is only appropriate during initial device detection (ata_identify)
# where a missing drive would otherwise loop forever.
# If successful, ALU flags will have the zero flag set.
# If timeout, ALU flags will not have zero flag set.
.ata_wait_ready
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

LDI_BH 0xFF                     # loop counter: 255 iterations before timeout

# Wait for busy flag to clear and ready flag to be set
.ata_wait_loop
ALUOP_BH %B-1%+%BH%             # decrement loop counter
JO .ata_wait_timeout             # underflow (was 0x00): timeout
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_busy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .ata_wait_loop              # continue waiting if busy flag is set
LDI_BL %ata_stat_rdy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_wait_loop               # continue waiting if ready flag is not set

ALUOP_AL %zero%                 # success, so ensure zero flag will be set
JMP .ata_wait_done

.ata_wait_timeout
ALUOP_AL %one%                  # timeout, so ensure zero flag will not be set

.ata_wait_done
# Set the ALU flags based on AL, which is zero on success
# or one on failure
ALUOP_FLAGS %A%+%AL%

POP_BH
POP_BL
POP_AL
RET

########
# :ata_drive_responsive
# Check if an ATA drive is responsive by passively polling the ATA
# status register (BSY=0, RDY=1) with a 1-second hardware watchdog
# timeout. No ATA command is issued: per ATA spec, the host must wait
# for BSY=0 and DRDY=1 before issuing any command, and writing to the
# command register while BSY=1 is explicitly prohibited. The drive
# asserting BSY=0/RDY=1 is itself the proof of presence; an absent
# drive leaves the bus floating at 0xFF (BSY=1 forever), causing timeout.
#
# To use this function:
#  * AL = drive ID (0=master, 1=slave). AL is consumed (not preserved).
#  * Call the function.
#  * Z flag set   = drive is responsive (BSY=0, RDY=1 within 1 second)
#  * Z flag clear = drive did not respond (timeout)
#  * Clobbers: AL (consumed as input), AH (used for timer args, then restored)
#  * Saves/restores: AH, BH, BL, IRQ3 vector
:ata_drive_responsive
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

# Select the drive
ALUOP_FLAGS %A%+%AL%
JZ .adr_master
ST_SLOW %ata_lba3% %ata_lba3_slave%
JMP .adr_selected
.adr_master
ST_SLOW %ata_lba3% %ata_lba3_master%
.adr_selected

# Save IRQ3 vector, install timer_incr_bh, arm 1-second watchdog
MASKINT
LD16_B %IRQ3addr%
ALUOP_PUSH %B%+%BH%             # save old IRQ3 high byte
ALUOP_PUSH %B%+%BL%             # save old IRQ3 low byte
ST16 %IRQ3addr% :timer_incr_bh # install handler
LDI_BH 0x00                     # BH = timer fire counter (0 = not yet fired)
LD_TD %tmr_ctrl_a%              # clear any pending timer interrupt
LDI_AH 0x01                     # 1 second watchdog
LDI_AL 0x00                     # 0 subseconds
CALL :timer_set_watchdog        # arm watchdog (consumes AH and AL)
UMASKINT

# Poll loop: wait for BSY=0, RDY=1
.adr_wait_loop
ALUOP_FLAGS %B%+%BH%
JNZ .adr_timeout                # BH!=0 means timer fired: drive not responsive
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_busy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .adr_wait_loop              # still busy, keep polling
LDI_BL %ata_stat_rdy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .adr_wait_loop               # not ready yet, keep polling

# Drive is responsive
ALUOP_AL %zero%
JMP .adr_done

.adr_timeout
ALUOP_AL %one%

.adr_done
# Disable watchdog and restore IRQ3 vector
MASKINT
ST %tmr_ctrl_b% %tmr_TE_mask%  # clear WDE bit, disable watchdog
POP_BL                           # old IRQ3 low byte
POP_BH                           # old IRQ3 high byte
ALUOP_ADDR %B%+%BH% %IRQ3addr%
ALUOP_ADDR %B%+%BL% %IRQ3addr%+1
UMASKINT

# Set Z flag for caller: AL=0 -> Z set (success), AL=1 -> Z clear (timeout)
ALUOP_FLAGS %A%+%AL%

POP_BL
POP_BH
POP_AH
RET

########
# .ata_set_lba_address
# Pop the master/slave byte from the heap into AL and swap
# it for the appropriate lba3 register mask, then pop the
# low LBA word from the heap and set that, then pop the
# high LBA word from the heap and set that.
.ata_set_lba_address
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

CALL :heap_pop_AL                   # master/slave in AL
ALUOP_FLAGS %A%+%AL%
JZ .ata_lba_master
LDI_AL %ata_lba3_slave%
JMP .ata_lba_1
.ata_lba_master
LDI_AL %ata_lba3_master%
.ata_lba_1

# Put the low word of the LBA address into C, then load it into the ATA bus
CALL :heap_pop_C
PUSH_CL
ST_SLOW_POP %ata_lba0%
PUSH_CH
ST_SLOW_POP %ata_lba1%
# Put the high word of the LBA address into C, then load it into the ATA bus
# Note that the top 4 bits of the LBA address must be:
# bit 4 - master(0) / slave(1)
# bit 5 - always 1
# bit 6 - 1 for LBA access
# bit 7 - always 1
CALL :heap_pop_C
PUSH_CL
ST_SLOW_POP %ata_lba2%
MOV_CH_BL
ALUOP_ADDR_SLOW %A|B%+%AL%+%BL% %ata_lba3%

POP_CL
POP_CH
POP_AL
RET


########
# .ata_wait_drive_ready
# Wait for the drive to become ready
.ata_wait_drive_ready
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
.ata_rdy_wait_loop
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_busy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .ata_rdy_wait_loop          # continue waiting if busy flag is set
LDI_BL %ata_stat_rdy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_rdy_wait_loop           # continue waiting if rdy flag is not set
POP_BL
POP_AL
RET

########
# .ata_wait_data_request_ready
# Wait for the drive to complete the requested operation.
.ata_wait_data_request_ready
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
.ata_drq_wait_loop
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_busy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .ata_drq_wait_loop          # continue waiting if busy flag is set
LDI_BL %ata_stat_drq%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_drq_wait_loop           # continue waiting if drq flag is not set
POP_BL
POP_AL
RET

########
# .ata_read_sector
# Read a 512-byte sector into the address at C
.ata_read_sector
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

LDI_BL 0xff                     # 256 words to read
.ata_read_loop
LD_SLOW_PUSH %ata_data%         # high byte on stack
POP_AL
ALUOP_ADDR_C %A%+%AL%           # write high byte to C
INCR_C
LD_AL %ata_lowreg%              # low byte in AL
ALUOP_ADDR_C %A%+%AL%           # write low byte to C
INCR_C
ALUOP_BL %B-1%+%BL%             # decrement BL
JNO .ata_read_loop              # keep looping until we overflow back to 0xff

POP_BL
POP_AL
RET

########
# .ata_write_sector
# Write a 512-byte sector from the address at C
.ata_write_sector
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

LDI_BL 0xff                     # 256 words to write
.ata_write_loop
INCR_C
LDA_C_AL                        # low byte in AL
ALUOP_ADDR %A%+%AL% %ata_lowreg% # low byte into lowreg
DECR_C
LDA_C_AL                        # high byte in AL
ALUOP_PUSH %A%+%AL%
ST_SLOW_POP %ata_data%          # write high+low byte to ATA
INCR_C
INCR_C

ALUOP_BL %B-1%+%BL%             # decrement BL
JNO .ata_write_loop             # keep looping until we overflow back to 0xff

POP_BL
POP_AL
RET

# Reset an ATA device by sending command 0x08
# To use:
#  1. Push a byte with the ATA id (0 or 1)
#  2. Call the function
#  3. Pop a status byte. 0x00 = success, non-zero
#     is an ATA error, 0xff is a timeout.
:ata_reset
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_CH
PUSH_CL

# Pop the master/slave byte from the heap into AL
# and set the %ata_lba3% register to the requested drive
CALL :heap_pop_AL                   # master/slave in AL
ALUOP_FLAGS %A%+%AL%
JZ .ata_reset_master
ST_SLOW %ata_lba3% %ata_lba3_slave%
JMP .ata_reset_1
.ata_reset_master
ST_SLOW %ata_lba3% %ata_lba3_master%
.ata_reset_1

# Wait for the newly selected drive to become ready - returns
# status via the ALU zero flag
CALL .ata_wait_ready
JNZ .ata_reset_timeout              # If timeout, abort

# Send the drive reset command
ST_SLOW %ata_cmd_stat% %ata_cmd_reset%

# Pause 100 milliseconds to give the drive a chance to begin reset
LDI_AH 0x00     # seconds
CALL :heap_push_AH
LDI_AH 0x10     # subseconds
CALL :heap_push_AH
CALL :sleep     # sleep for 0.1 sec

# Wait for drive to be ready
CALL .ata_wait_drive_ready

# Return success
LDI_AL 0x00
CALL :heap_push_AL
JMP .ata_reset_done

# Return failure on timeout
.ata_reset_timeout
LD_SLOW_PUSH %ata_err%
POP_AL
CALL :heap_push_AL

.ata_reset_done
POP_CL
POP_CH
POP_AL
POP_AH
RET

