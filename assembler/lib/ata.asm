# vim: syntax=asm-mycpu

# ATA port functions
# https://blog.retroleum.co.uk/electronics-articles/an-8-bit-ide-interface/


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

# Wait for drive to become ready - returns
# status via the ALU zero flag
CALL .ata_wait_ready

# If timeout, abort
JNZ .ata_id_timeout

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
# .ata_wait_ready
# Wait for the drive to become ready. If successful,
# ALU flags will have the zero flag set.  If timeout,
# ALU flags will not have zero flag set.
.ata_wait_ready
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

MASKINT
LD16_B %IRQ3addr%               # save IRQ3 vector
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
ST16 %IRQ3addr% :timer_incr_bh  # increment BH when timer fires

ST %tmr_wdog_sec%       0x00    # set watchdog timer to 500ms
ST %tmr_wdog_subsec%    0x50

LDI_BH 0x00                     # set initial timer state

LD_TD   %tmr_ctrl_a%            # read control_a register, this
                                # clears any pending interrupts
# set control_b (control) bits
# TE=1 (enable transfers)
# CS=0 (don't care)
# BME=0 (disable burst mode)
# TPE=0 (alarm power-enable)
# TIE=0 (alarm interrupt-enable)
# KIE=0 (kickstart enable)
# WDE=1 (watchdog enabled)
# WDS=0 (watchdog steers to IRQ)
ST      %tmr_ctrl_b%        %tmr_TE_mask%+%tmr_WDE_mask%
# enable interrupts
UMASKINT

# Wait for busy flag to clear and ready flag to be set
.ata_wait_loop
ALUOP_FLAGS %B%+%BH%            # check timer flag
JNZ .ata_wait_timeout           # abort on timeout
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
ALUOP_AL %one%                  # timeout, so ensure zero flag will be set

.ata_wait_done
MASKINT
POP_BL
POP_BH
ALUOP_ADDR %B%+%BH% %IRQ3addr%
ALUOP_ADDR %B%+%BL% %IRQ3addr%+1
UMASKINT

# Set the ALU flags based on AL, which is zero on success
# or one on failure
ALUOP_FLAGS %A%+%AL%

POP_BH
POP_BL
POP_AL
RET

# Wait for data request ready
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

# Read a 512-byte sector into the address at C
.ata_read_sector
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

LDI_BL 0xff                     # 256 words to read
.ata_read_loop
LD_SLOW_PUSH %ata_data%         # low byte on stack
POP_AL
ALUOP_ADDR_C %A%+%AL%           # write low byte to C
INCR_C
LD_AL %ata_hireg%               # high byte in AL
ALUOP_ADDR_C %A%+%AL%           # write high byte to C
INCR_C
ALUOP_BL %B-1%+%BL%             # decrement BL
JNO .ata_read_loop              # keep looping until we overflow back to 0xff

POP_BL
POP_AL
RET
