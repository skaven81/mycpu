# vim: syntax=asm-mycpu

# Timer utility functions

######
# Timer-controlled sleep
#  AH: BCD seconds
#  AL: BCD subseconds
# Upon return, AL will contain 0x01 if the timer
# triggered the exit from the sleep function
:sleep
PUSH_DH
PUSH_DL

MASKINT

# Save the current IRQ3 vector
LD_DH   %IRQ3addr%
LD_DL   %IRQ3addr%+1
PUSH_DH
PUSH_DL

# Set up timer interrupt to use our function
ST16    %IRQ3addr%  .sleep_timer

# set watchdog timer to interval specified by AH and AL
ALUOP_ADDR %A%+%AH% %tmr_wdog_sec%
ALUOP_ADDR %A%+%AL% %tmr_wdog_subsec%

LDI_AL  0  # set up spinlock

# set control_a (flag) bits to zeroes, this
# also clears any pending interrupts
ST      %tmr_ctrl_a%        0x00
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

# loop until spinlock flips
.sleep_wait
ALUOP_FLAGS %A%+%AL%
JZ .sleep_wait
MASKINT

# Restore IRQ3 address
POP_DL
POP_DH
ST_DH   %IRQ1addr%
ST_DL   %IRQ1addr%+1

# Restore D register
POP_DL
POP_DH

UMASKINT

RET

.sleep_timer
LDI_AL  1                       # toggle our spinlock when timer triggers
ST %tmr_ctrl_a% 0x00            # clear interrupt
ST %tmr_ctrl_b% %tmr_TE_mask%   # clear WDE bit
RETI

######
# no-op target that does nothing else
# but clear the timer IRQ
:timer_clear_irq
ST %tmr_ctrl_a% 0x00
RETI
