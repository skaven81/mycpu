# vim: syntax=asm-mycpu

# Set the UART config

:cmd_setserial

# Initialize argv: AL=argc, C=argv base
CALL :argv_init
LDI_D .argv_buf
LDI_AL 3                         # 4 blocks = 64 bytes
CALL :memcpy_blocks              # copy argv array to local buffer

LDI_A .argv_buf+2               # A points at first argument pointer
LDA_A_CH                        # put high byte of first arg pointer into CH
ALUOP16O_A %ALU16_A+1%
LDA_A_CL                        # put low byte of first arg pointer into CL
ALUOP16O_A %ALU16_A+1%
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

LDI_D .baud0
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_1200
LDI_D .baud1
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_2400
LDI_D .baud2
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_4800
LDI_D .baud3
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_9600
LDI_D .baud4
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_19200
LDI_D .baud5
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_38400
LDI_D .baud6
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_57600
LDI_D .baud7
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_115200
JMP .usage

.set_1200
CALL :uart_init_1200_8n1
JMP .done
.set_2400
CALL :uart_init_2400_8n1
JMP .done
.set_4800
CALL :uart_init_4800_8n1
JMP .done
.set_9600
CALL :uart_init_9600_8n1
JMP .done
.set_19200
CALL :uart_init_19200_8n1
JMP .done
.set_38400
CALL :uart_init_38400_8n1
JMP .done
.set_57600
CALL :uart_init_57600_8n1
JMP .done
.set_115200
CALL :uart_init_115200_8n1
JMP .done

.done
CALL :heap_push_C
LDI_C .setstr
CALL :printf
JMP .program_exit

.usage
LDI_C .helpstr
CALL :print
JMP .program_exit

.program_exit
LDI_A 0x0000
CALL :heap_push_A
RET

.helpstr "Usage: setserial {1200,2400,4800,9600,19200,38400,57600,115200}\n\0"
.setstr "UART set to %s,8,n,1\n\0"
.baud0 "1200\0"
.baud1 "2400\0"
.baud2 "4800\0"
.baud3 "9600\0"
.baud4 "19200\0"
.baud5 "38400\0"
.baud6 "57600\0"
.baud7 "115200\0"
.argv_buf "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

