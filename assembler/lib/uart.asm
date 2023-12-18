# vim: syntax=asm-mycpu

#####
# UART management functions
#####

######
# Initializes the UART to a particular speed setting
:uart_init_1200_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_1200%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_2400_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_2400%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_4800_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_4800%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_9600_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_9600%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_19200_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_19200%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_38400_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_38400%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_57600_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_57600%+%uart_brsr_cobaud%
JMP .uart_init

:uart_init_115200_8n1
ST %uart_ucr% %uart_ucr_8n1%
ST %uart_brsr% %uart_brsr_115200%+%uart_brsr_cobaud%
JMP .uart_init

######
# Initializes the UART.  Docs indicate that a proper software reset should
# happen in this order:
#  1. write to UCR (done above)
#  2. write to BRSR (done above)
#  3. write to MCR
#  4. read USR
#  5. read RBR
#  6. enable interrupts
.uart_init
# RTS & DTR unset
# ITEN unset - INTR (IRQ5) will not fire on errors
# mode=0, normal
# REN receiver enabled
# MIEN unset - do not trigger interrupts on DSR/CTS line changes
ST %uart_mcr% %uart_mcr_REN%

# read MSR to clear status bits and interrupts
LD_TD %uart_msr%
# read USR to clear status bits and interrupts
LD_TD %uart_usr%
# read RBR to clear received data and interrupts
LD_TD %uart_rbr%

# initialize uart buffer pointer
ST16 $uart_buf_ptr_write 0xbd00
ST16 $uart_buf_ptr_read 0xbd00

RET

######
# IRQ4 (INTR) target that does nothing except read from the
# USR and MSR registers to clear the interrupt.
:uart_clear_usr_msr
LD_TD %uart_msr%
LD_TD %uart_usr%
RETI

######
# IRQ5 (DR/data ready) target that does nothing but clear
# the interrupt
:uart_clear_dr
LD_TD %uart_rbr%
RETI

######
# IRQ5 (DR/data ready) target that reads from the UART's receive buffer
# register (RBR) and shifts it into the uart read buffer in RAM. Like
# the keyboard read buffer, the write address pointer is incremented and
# wraps around after 256 bytes.  The read pointer "chases" the write
# pointer.  When the two pointers are identical, the buffer is empty.
VAR global word $uart_buf_ptr_write
VAR global word $uart_buf_ptr_read
:uart_irq_dr_buf
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%

LD_AH   $uart_buf_ptr_write
LD_AL   $uart_buf_ptr_write+1
LD_BH   %uart_rbr%
ALUOP_ADDR_A %B%+%BH%                           # write character to buffer
ALUOP_ADDR %A+1%+%AL% $uart_buf_ptr_write+1     # increment write pointer, wraps back to 00

POP_BH
POP_AH
POP_AL
RETI

######
# Returns the UART read buffer size in AL, will be
# a value from zero (nothing in the buffer) to 0xff
# (255 characters in buffer).
:uart_bufsize
ALUOP_PUSH %B%+%BL%

LD_AL $uart_buf_ptr_write+1
LD_BL $uart_buf_ptr_read+1
ALUOP_AL %A-B%+%AL%+%BL%    # write_addr - read_addr = bufsize. If read_addr>write_addr,
                            # result is negative, but wraps around so we still get the
POP_BL                      # absolute value back.
RET

######
# Read a character into AL from the UART read buffer. If the
# buffer is empty, returns 0x00. You have to use :uart_bufsize
# to distinguish between a received NULL and an empty buffer.
:uart_readbuf
CALL :uart_bufsize
ALUOP_FLAGS %A%+%AL%
JNZ .uart_readbuf_fetch
# if AL was zero, put 0x00 in AL and return
LDI_AL 0x00
RET
.uart_readbuf_fetch
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD_BH   $uart_buf_ptr_read
LD_BL   $uart_buf_ptr_read+1
LDA_B_AL                # load the character into AL
ALUOP_ADDR %B+1%+%BL% $uart_buf_ptr_read+1 # save new read pointer back to RAM

POP_BL
POP_BH
RET

#####
# Write a character from AL.  Blocks until the UART
# confirms the byte has been sent.
:uart_sendchar
ALUOP_PUSH %B%+%BL%
LDI_BL %uart_usr_TC%            # TC flag gets set when transfer is complete
ALUOP_ADDR %A%+%AL% %uart_tbr%  # put the char into the uart xmit buffer
.uart_xmit_loop
LD_AL %uart_usr%
ALUOP_FLAGS %A&B%+%AL%+%BL%     # See if transmission complete flag is set
JZ .uart_xmit_loop              # loop until byte has been sent
POP_BL
RET

