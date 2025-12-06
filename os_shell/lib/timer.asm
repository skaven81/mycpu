# vim: syntax=asm-mycpu

# Timer utility functions

######
# Configure the timer to repetitively trigger an interrupt on
# IRQ3 in the time interval specified on the heap.
#
# Usage:
#  * push the BCD-encoded seconds to the heap (00-99)
#  * push the BCD-encoded subseconds to the heap (00-99)
#  * call the function
:timer_set_watchdog
ALUOP_PUSH %A%+%AL%
# set watchdog timer to interval specified by AH and AL
CALL :heap_pop_AL                       # subseconds
ALUOP_ADDR %A%+%AL% %tmr_wdog_subsec%
CALL :heap_pop_AL                       # seconds
ALUOP_ADDR %A%+%AL% %tmr_wdog_sec%
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
POP_AL
RET

######
# Configure the timer in an idle state, which suppresses
# regular interrupts and has the clock updating.
:timer_set_idle
# set control_b (control) bits
# TE=1 (enable transfers)
# CS=0 (don't care)
# BME=0 (disable burst mode)
# TPE=0 (alarm power-enable)
# TIE=0 (alarm interrupt-enable)
# KIE=0 (kickstart enable)
# WDE=0 (watchdog enabled)
# WDS=0 (watchdog steers to IRQ)
ST      %tmr_ctrl_b%        %tmr_TE_mask%
RET

######
# Timer-controlled sleep
#  * push BCD seconds to heap (00-99)
#  * push BCD subsec to heap (0-99)
:sleep
PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

MASKINT

# Save the current IRQ3 vector
LD_DH   %IRQ3addr%
LD_DL   %IRQ3addr%+1
PUSH_DH
PUSH_DL

# Set up timer interrupt to use our function
ST16    %IRQ3addr%  .sleep_timer

LDI_AL  0  # set up spinlock

# read control_a register, this
# clears any pending interrupts
LD_TD   %tmr_ctrl_a%
CALL :timer_set_watchdog        # This will pop the two values from the heap

# Now that timer is setup, enable interrupts
UMASKINT

# loop until spinlock flips
.sleep_wait
ALUOP_FLAGS %A%+%AL%
JZ .sleep_wait
MASKINT

# Shutdown the watchdog timer so it stops interrupting us
CALL :timer_set_idle

# Restore IRQ3 address
POP_DL
POP_DH
ST_DH   %IRQ3addr%
ST_DL   %IRQ3addr%+1

# Restore registers
POP_AL
POP_DL
POP_DH

UMASKINT

RET

.sleep_timer
LDI_AL  1                       # toggle our spinlock when timer triggers
LD_TD %tmr_ctrl_a%              # clear interrupt
ST %tmr_ctrl_b% %tmr_TE_mask%   # clear WDE bit
RETI

######
# no-op target that does nothing else
# but clear the timer IRQ
:timer_clear_irq
LD_TD %tmr_ctrl_a%
RETI


######
# timer target that increments the BH register
# and clears the timer IRQ
:timer_incr_bh
LD_TD %tmr_ctrl_a%              # clear timer IRQ
ALUOP_BH %B+1%+%BH%
RETI

