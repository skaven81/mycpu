# vim: syntax=asm-mycpu

#####
# Keyboard management functions
#####

######
# Initializes the keyboard by waiting 750ms and then
# clearing any keyboard interrupts.
:keyboard_init
MASKINT                 # Don't process interrupts until we're ready

PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

####
# Save the current IRQ1 address
LD_DH   %IRQ1addr%
LD_DL   %IRQ1addr%+1
PUSH_DH
PUSH_DL

####
# Set up IRQ1 to use our handler
ST16    %IRQ1addr%  :kb_clear_irq

####
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
# no-op target for IRQ1 that clears the
# interrupt but does nothing else
:kb_clear_irq
LD_TD %kb_key%
RETI
