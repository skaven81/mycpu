# vim: syntax=asm-mycpu

#######
# Computes the current CPU clock speed, in kHz, using the timer.
#
# The timer is set to interrupt after 0.1 sec, and we count the
# number of loop iterations that have passed.  If we assume that
# each loop iteration takes just one clock, then the counter will
# contain 0.1*ticks.  Ex. for a 2,000,000Hz clock, the counter would
# contain 200,000.  Thus to get to kHz, we need our counter loop
# to take exactly 100 clock ticks.  That way, the counter ends
# up containing the number of hundreds of clock ticks that took
# place over one tenth of a second, which is equivalent to the
# number of thousands of clock ticks that take place over a full
# second, or in other words, kHz.
#
# Input:
#   None
# Output:
#   A will contain the computed clock speed in kHz
:sys_clock_speed
PUSH_DH
PUSH_DL
ALUOP_PUSH %B%+%BL%

MASKINT

# Save the current IRQ3 vector to the stack
LD_DH   %IRQ3addr%
LD_DL   %IRQ3addr%+1
PUSH_DH
PUSH_DL

# Set up timer interrupt to use our function
ST16    %IRQ3addr%  .sys_clock_speed_timer

# set watchdog timer to 0.1 sec
ST      %tmr_wdog_sec%      0x00 # BCD
ST      %tmr_wdog_subsec%   0x10 # BCD

LDI_AL  0  # set up spinlock
LDI_DH  0
LDI_DL  0

# read control_a register, this
# clears any pending interrupts
LD_TD   %tmr_ctrl_a%
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

# loop until spinlock ticks to 1. We don't count ticks
# here because the first interrupt may come anywhere
# from zero to 0.1 sec.
LDI_BL  1
.sys_clock_speed_wait
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .sys_clock_speed_wait

# We now want to count iterations of this loop, which
# should take 100 clocks, until AL >= 2.
LDI_BL  2
VAR global word $dummy              # ST16 takes 11 clocks but we need somewhere to write data
.sys_clock_speed_wait2              # op        total
ST16 $dummy 0x0000                  # 12        12
ST16 $dummy 0x0000                  # 12        24
ST16 $dummy 0x0000                  # 12        36
ST16 $dummy 0x0000                  # 12        48
ST16 $dummy 0x0000                  # 12        60
ST16 $dummy 0x0000                  # 12        72
ST16 $dummy 0x0000                  # 12        84
LD_TD $dummy                        # 5         89
INCR_D                              # 2         91
ALUOP_FLAGS %AxB%+%AL%+%BL%         # 4         95
JNE .sys_clock_speed_wait2          # 5 if NE   100
#ALUOP_FLAGS %A-B%+%AL%+%BL%         # 4         95
#JNO .sys_clock_speed_wait2          # 5 if NO   100

MASKINT

# Turn off the timer interrupts
ST %tmr_ctrl_b% %tmr_TE_mask%   # clear WDE bit

# Store the kHz in A
MOV_DL_AL
MOV_DH_AH

# Restore IRQ3 address
POP_DL
POP_DH
ST_DH   %IRQ3addr%
ST_DL   %IRQ3addr%+1

POP_BL
POP_DL
POP_DH

UMASKINT

RET

.sys_clock_speed_timer
ALUOP_AL %A+1%+%AL%
LD_TD %tmr_ctrl_a%              # clear interrupt
RETI


#######
# Utility functions to push and pop the entire register stack,
# which is about twice as fast as heap_push/pop_all, but eats
# valuable stack space.
:push_all
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%BH%
ALUOP_PUSH %A%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL
RET

:pop_all
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
