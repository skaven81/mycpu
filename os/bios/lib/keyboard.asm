# vim: syntax=asm-mycpu

#####
# Keyboard management functions
#####

######
# Initializes the keyboard by waiting 750ms and then
# clearing any keyboard interrupts.
:keyboard_init
MASKINT                 # Don't process interrupts until we're ready

# initialize keyboard buffer pointer
ST16 $kb_buf_ptr_write 0xbe00
ST16 $kb_buf_ptr_read 0xbe00

PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

# Save the current IRQ1 address
LD_DH   %IRQ1addr%
LD_DL   %IRQ1addr%+1
PUSH_DH
PUSH_DL

# Set up IRQ1 to use our handler
ST16    %IRQ1addr%  :kb_clear_irq

# Pause for 0.75 sec
LDI_AH  0x00    # BCD, seconds
CALL :heap_push_AH
LDI_AH  0x75    # BCD, subseconds
CALL :heap_push_AH
CALL :sleep     # Sleep for 0.75 sec

# Restore IRQ1 address
POP_DL
POP_DH
ST_DH   %IRQ1addr%
ST_DL   %IRQ1addr%+1

POP_AL
POP_DL
POP_DH
RET



######
# IRQ1 target that reads the keystroke into the keyboard buffer.  The
# write address pointer is incremented and wraps around.  The read
# pointer "chases" the write pointer.  When the two pointers are identical,
# the buffer is empty.
VAR global word $kb_buf_ptr_write
VAR global word $kb_buf_ptr_read
:kb_irq_buf
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BH%

LD_AH   $kb_buf_ptr_write
LD_AL   $kb_buf_ptr_write+1
LD_BH   %kb_keyflags%
ALUOP_ADDR_A    %B%+%BH%    # write keyflags to buffer write location
ALUOP_AL %A+1%+%AL%         # increment write pointer, wraps back to 00
LD_BH   %kb_key%
ALUOP_ADDR_A    %B%+%BH%    # write key to buffer write location
ALUOP_AL %A+1%+%AL%         # increment write pointer, wraps back to 00

# write lower byte of write address back
ALUOP_ADDR %A%+%AL% $kb_buf_ptr_write+1

POP_BH
POP_AH
POP_AL
RETI

######
# Returns the keyboard buffer size in AL, will be
# a value from zero (nothing in the buffer) to 0xd
# (7 keystrokes in buffer).
:kb_bufsize
ALUOP_PUSH %B%+%BL%

LD_AL $kb_buf_ptr_write+1
LD_BL $kb_buf_ptr_read+1
ALUOP_AL %A-B%+%AL%+%BL%    # write_addr - read_addr = bufsize. If read_addr>write_addr,
                            # result is negative, but wraps around so we still get the
POP_BL                      # absolute value back.
RET

######
# Read a keystroke into AH (flags) and AL (char) from the keyboard buffer. If the
# buffer is empty, returns 0x00 in both registers.
:kb_readbuf
CALL :kb_bufsize
ALUOP_FLAGS %A%+%AL%
JNZ .kb_readbuf_fetch
# if AL was zero, put 0x00 in AH and AL and return
LDI_A 0x0000
RET
.kb_readbuf_fetch
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
LD_BH   $kb_buf_ptr_read
LD_BL   $kb_buf_ptr_read+1
LDA_B_AH                # load the keyflags into AH
ALUOP_BL %B+1%+%BL%     # increment BL
LDA_B_AL                # load the character into AL
ALUOP_BL %B+1%+%BL%     # increment BL
ALUOP_ADDR %B%+%BL% $kb_buf_ptr_read+1 # save new read pointer back to RAM

POP_BL
POP_BH
RET


######
# no-op target for IRQ1 that clears the
# interrupt but does nothing else
:kb_clear_irq
LD_TD %kb_key%
RETI
