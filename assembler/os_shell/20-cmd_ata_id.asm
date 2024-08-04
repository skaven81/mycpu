# vim: syntax=asm-mycpu

# ATA ID command

:cmd_ata_id

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage                       # abort with usage message if null

LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

ALUOP_BL %A%+%AL%               # Save the start address in B
ALUOP_BH %A%+%AH%

CALL :heap_push_A               # destination address
LDI_AL 0x00                     # master drive
CALL :heap_push_AL
CALL :ata_identify              # status byte on heap
CALL :heap_push_BL              # low address byte
CALL :heap_push_BH              # high address byte
LDI_C .master_read_out
CALL :printf

### DEBUG
RET

LDI_A 512
CALL :add16_to_b                # Increment start address by 512

CALL :heap_push_B               # destination address
LDI_AL 0x01                     # slave drive
CALL :heap_push_AL
CALL :ata_identify              # status byte on heap
CALL :heap_push_BL              # low address byte
CALL :heap_push_BH              # high address byte
LDI_C .slave_read_out
CALL :printf

RET

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: ata-id <sector-addr> (writes master ID to 0-511, slave ID to 512-1023)\n\0"
.bad_addr_str "Error: %s is not a valid address. strtoi flags: 0x%x\n\0"
.master_read_out "Master ID read into 0x%x%x with status 0x%x\n\0"
.slave_read_out " Slave ID read into 0x%x%x with status 0x%x\n\0"
