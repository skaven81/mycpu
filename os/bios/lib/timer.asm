# vim: syntax=asm-mycpu

# Timer utility functions

######
# Configure the timer to trigger an interrupt on IRQ3 after the
# specified interval. The DS1511Y watchdog is a one-shot timer:
# it fires once and stops. To implement a periodic interrupt (e.g.
# for frame rendering), the ISR itself must call this function again
# after clearing the interrupt via LD_TD %tmr_ctrl_a%.
#
# This function intentionally uses registers rather than the heap
# so that it is safe to call from within an ISR. Heap functions
# internally call UMASKINT, which would re-enable interrupts mid-ISR
# and risk re-entrant handler execution or heap pointer corruption.
# Direct register writes have no such side effects.
#
# Usage:
#  * AH = BCD-encoded seconds (00-99)
#  * AL = BCD-encoded subseconds (00-99)
#  * call the function
#  * AH and AL are consumed (not preserved)
:timer_set_watchdog
ALUOP_ADDR %A%+%AL% %tmr_wdog_subsec%
ALUOP_ADDR %A%+%AH% %tmr_wdog_sec%
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
#  * push BCD subsec to heap (00-99)
:sleep
PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

MASKINT

# Save the current IRQ3 vector
LD_DH   %IRQ3addr%
LD_DL   %IRQ3addr%+1
PUSH_DH
PUSH_DL

# Set up timer interrupt to use our function
ST16    %IRQ3addr%  .sleep_timer

# Load sleep duration from heap into AH=seconds, AL=subseconds.
# Heap was pushed seconds-first, subseconds-second, so subseconds
# is on top and must be popped first, then seconds.
CALL :heap_pop_AL               # subseconds -> AL
CALL :heap_pop_AH               # seconds -> AH

# read control_a register, this clears any pending interrupts
LD_TD   %tmr_ctrl_a%
CALL :timer_set_watchdog        # AH=seconds, AL=subseconds (both consumed)

LDI_AL  0  # set up spinlock

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
POP_AH
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

