# vim: syntax=asm-mycpu

# Keyboard management functions


:keyboard_init
######
# Initializes the keyboard by waiting 100ms and then
# clearing any keyboard interrupts.
######
MASKINT                 # Don't process interrupts until we're ready

PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

####
# Save the current IRQ1 and IRQ3 addresses.  Use D because it's mangled by
# the ST16 instruction, so this reduces the backup/restore work we have to do
LD_DH   %IRQ1addr%
LD_DL   %IRQ1addr%+1
PUSH_DH
PUSH_DL
LD_DH   %IRQ3addr%
LD_DL   %IRQ3addr%+1
PUSH_DH
PUSH_DL

####
# Set up interrupts
ST16    %IRQ1addr%  .clear_kb_irq
ST16    %IRQ3addr%  .timer

####
# Use the timer to wait 1 sec for the ATTiny to boot
LDI_AL  0  # set up spinlock
# set watchdog timer to 00.75 sec intervals
ST      %tmr_wdog_sec%      0x00  # BCD
ST      %tmr_wdog_subsec%   0x75  # BCD
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
.kb_init_wait
ALUOP_FLAGS %A%+%AL%
JZ .kb_init_wait
MASKINT

# Restore IRQ1 and IRQ3 addresses
POP_DL
POP_DH
ST_DH   %IRQ3addr%
ST_DL   %IRQ3addr%+1
POP_DL
POP_DH
ST_DH   %IRQ1addr%
ST_DL   %IRQ1addr%+1

POP_AL
POP_DL
POP_DH
RET

.timer
LDI_AL  1                       # toggle our spinlock when timer triggers
ST %tmr_ctrl_a% 0x00            # clear interrupt
ST %tmr_ctrl_b% %tmr_TE_mask%   # clear WDE bit
RETI

.clear_kb_irq
LD_TD %kb_key%
RETI
