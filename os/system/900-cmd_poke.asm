# vim: syntax=asm-mycpu

# Poke a byte

:cmd_poke

# Check for a first argument
LDI_AL 1
CALL :shell_get_argv_n          # A = argv[1] string address
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Check for a second argument
LDI_AL 2
CALL :shell_get_argv_n          # A = argv[2] string address
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Load and check address
LDI_AL 1
CALL :shell_get_argv_n          # A = argv[1] string address
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv[1] string
CALL :strtoi                    # Convert to number in A, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_address

# Store address on stack for now
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

# Load and check byte
LDI_AL 2
CALL :shell_get_argv_n          # A = argv[2] string address
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%               # C = argv[2] string
CALL :strtoi8                   # Convert to number in AL, BL has flags
ALUOP_FLAGS %B%+%BL%
JNZ .abort_bad_byte

ALUOP_DL %A%+%AL%               # Put byte to write into DL
POP_AL
POP_AH                          # Address popped back into A

LDA_A_SLOW_PUSH
POP_DH                          # get current byte into DH
PUSH_DL
STA_A_SLOW_POP                  # replace with DL
CALL :heap_push_DL
CALL :heap_push_DH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .updated_str
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

.abort_bad_byte
POP_TD                          # Discard saved address
POP_TD
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .bad_byte_str
CALL :printf
RET


.helpstr "Usage: poke <addr> <byte>\n\0"
.bad_addr_str "Error: %s is not a valid address. strtoi flags: 0x%x\n\0"
.bad_byte_str "Error: %s is not a valid byte specifier. strtoi flags: 0x%x\n\0"
.updated_str "0x%x%x: was 0x%x now 0x%x\n\0"
