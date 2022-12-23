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
ST16 $kb_buf_ptr_write 0xbef0
ST16 $kb_buf_ptr_read 0xbef0

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
LDI_AL  0x75    # BCD, subseconds
CALL :sleep

# Restore IRQ1 address
POP_DL
POP_DH
ST_DH   %IRQ3addr%
ST_DL   %IRQ3addr%+1

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
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

LD_AH   $kb_buf_ptr_write
LD_AL   $kb_buf_ptr_write+1
LD_BH   %kb_keyflags%
LDI_BL   0xf0               # mask for ring buffer, lower byte of 0xbef0
ALUOP_ADDR_A    %B%+%BH%    # write keyflags to buffer write location
ALUOP_AL %A+1%+%AL%         # increment write pointer
ALUOP_AL %A|B%+%AL%+%BL%    # mask to keep lower byte between f0 and ff
LD_BH   %kb_key%
ALUOP_ADDR_A    %B%+%BH%    # write key to buffer write location
ALUOP_AL %A+1%+%AL%         # increment write pointer
ALUOP_AL %A|B%+%AL%+%BL%    # mask to keep lower byte between f0 and ff

# write lower byte of write address back
ALUOP_ADDR %A%+%AL% $kb_buf_ptr_write+1

POP_BH
POP_BL
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
ALUOP_AL %A-B%+%AL%+%BL%    # write_addr - read_addr = bufsize (but might be negative if write has wrapped)
LDI_BL 0x0f
ALUOP_AL %A&B%+%AL%+%BL%    # mask off the top four bits to get the absolute value

POP_BL
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
ALUOP_PUSH %A%+%AH%     # ..and push onto stack as we still need AH for computation
LDI_AH  0xf0            # mask for wrapping read address
ALUOP_BL %B+1%+%BL%
ALUOP_BL %A|B%+%AH%+%BL% # increment BL but wrap ff to f0
LDA_B_AL                # load the character into AL
ALUOP_BL %B+1%+%BL%
ALUOP_BL %A|B%+%AH%+%BL% # increment BL but wrap ff to f0
ALUOP_ADDR %B%+%BL% $kb_buf_ptr_read+1 # save read pointer back to RAM

POP_AH                  # get keyflags off the stack

POP_BL
POP_BH
RET


######
# no-op target for IRQ1 that clears the
# interrupt but does nothing else
:kb_clear_irq
LD_TD %kb_key%
RETI
