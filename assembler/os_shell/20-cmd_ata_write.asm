# vim: syntax=asm-mycpu

# Write a sector to the ATA bus
#  Argument 1 (+2/3): master (0) or slave (1) byte
#  Argument 2 (+4/5): LBA address high word
#  Argument 3 (+6/7): LBA address low word
#  Argument 4 (+8/9): source address

:cmd_ata_write

# Check for a first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_D $user_input_tokens+4      # D points at second argument pointer
LDA_D_AH                        # put second arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a third argument
LDI_D $user_input_tokens+6      # D points at third argument pointer
LDA_D_AH                        # put third arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a third argument
LDI_D $user_input_tokens+8      # D points at fourth argument pointer
LDA_D_AH                        # put fourth arg pointer into A
INCR_D                          # |
LDA_D_AL                        # |
INCR_D                          # |
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

## Load and check destination address into D
LDI_A $user_input_tokens+8      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+9      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_DH %A%+%AH%               # Copy destination address to D for now
ALUOP_DL %A%+%AL%

## Load and check low LBA address into C
LDI_A $user_input_tokens+6      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+7      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_CH %A%+%AH%               # Copy low LBA address to C for now
ALUOP_CL %A%+%AL%

## Load and check high LBA address into B
PUSH_CH
PUSH_CL
LDI_A $user_input_tokens+4      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+5      # |
LDA_A_CL                        # |
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address
ALUOP_BH %A%+%AH%               # Copy low LBA address to C for now
ALUOP_BL %A%+%AL%
POP_CL
POP_CH

## Load and check master/slave into AL
PUSH_CH
PUSH_CL
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
LDA_C_AL                        # load first char into AL
POP_CL
POP_CH
ALUOP_PUSH %B%+%BL%
LDI_BL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_master
LDI_BL 'm'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_master
LDI_BL 'M'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_master
LDI_BL '1'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_slave
LDI_BL 's'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_slave
LDI_BL 'S'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .set_al_slave
# if no match 0/1/m/s then abort
POP_BL
JMP .abort_bad_ms

.set_al_master
LDI_AL 0x00
JMP .write_continue

.set_al_slave
LDI_AL 0x01
JMP .write_continue

.write_continue
POP_BL # restore BL from before we started testing 0/1/m/s

CALL :heap_push_D       # Push destination address to heap
CALL :heap_push_B       # Push high LBA word to heap
CALL :heap_push_C       # Push low LBA word to heap
CALL :heap_push_AL      # Push master/slave byte to heap

CALL :ata_write_lba     # status returned in byte on heap
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%    # check for zero
JZ .success

.failed
CALL :heap_push_AL
LDI_C .error_str
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.abort_bad_address
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_addr_str
CALL :printf
RET

.abort_bad_ms
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_ms_str
CALL :printf
RET

.success
CALL :heap_push_DL      # destination address
CALL :heap_push_DH
CALL :heap_push_CL      # LBA low
CALL :heap_push_CH
CALL :heap_push_BL      # LBA high
CALL :heap_push_BH
LDI_C .complete_str
CALL :printf
RET

.helpstr "Usage: ata-write {0/m|1/s} <lba 27:16> <lba 15:0> <src-addr>\n\0"
.bad_addr_str "Error: %s is not a valid 16-bit word. strtoi flags: 0x%x\n\0"
.bad_ms_str "Error: %s is not a valid ATA master/slave specifier. Must be 0/m or 1/s\n\0"
.complete_str "Sector 0x%x%x%x%x written from 0x%x%x\n\0"
.error_str "Unable to write device, error flags: 0b%2\n\0"
