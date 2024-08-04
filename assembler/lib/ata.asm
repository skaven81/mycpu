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

# Wait for drive to become ready
CALL .ata_wait_ready

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


# Wait for the drive to become ready
.ata_wait_ready
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
.ata_wait_loop
LD_SLOW_PUSH %ata_cmd_stat%
POP_AL
LDI_BL %ata_stat_busy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .ata_wait_loop              # continue waiting if busy flag is set
LDI_BL %ata_stat_rdy%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .ata_wait_loop               # continue waiting if ready flag is not set
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
