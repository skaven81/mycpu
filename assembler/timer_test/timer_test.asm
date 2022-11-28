# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays the current time stored
# in the timer, and updates the display once per second,
# using the watchdog interrupt feature.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  .irq1
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  .irq3
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

#######
# Main loop
#######

# set watchdog timer to 00.25 sec intervals
ST      %tmr_wdog_sec%      0x00  # BCD
ST      %tmr_wdog_subsec%   0x25  # BCD
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

UMASKINT                # Enable interrupts
.main_loop
JMP .main_loop
HLT

#######
# IRQ handlers
#######

.irq1
LD_TD   %kb_key%                    # Keep the KB interrupt clear
RETI

.irq3
# read the timer flags - this clears the IRQ
LD_AL   %tmr_flags%

LD_AL   %tmr_clk_sec%               # read seconds - in BCD
LDI_BL  0x0f                        # lower byte mask
ALUOP_PUSH  %A&B%                   # push the seconds onto the stack
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_PUSH  %A>>1%                  # push the tens of seconds onto the stack
LD_AL   %tmr_clk_min%               # read minutes - in BCD
ALUOP_PUSH  %A&B%                   # push the minutes onto the stack
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_PUSH  %A>>1%                  # push the tens of minutes onto the stack
LD_AL   %tmr_clk_hr%                # read hours - in BCD
ALUOP_PUSH  %A&B%                   # push the hours onto the stack
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_AL    %A>>1%
ALUOP_PUSH  %A>>1%                  # push the tens of hours onto the stack

# Now write the time to the display
LDI_C   %display_chars%+100         # where to print data
LDI_BL  '0'                         # add to each BCD digit

POP_AL                              # tens of hours in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen
INCR_C
POP_AL                              # hours in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen
INCR_C

LDI_TD  ':'
STA_C_TD
INCR_C

POP_AL                              # tens of minutes in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen
INCR_C
POP_AL                              # minutes in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen
INCR_C

LDI_TD  ':'
STA_C_TD
INCR_C

POP_AL                              # tens of seconds in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen
INCR_C
POP_AL                              # seconds in AL
ALUOP_ADDR_C %A+B%                  # ASCII to screen

LD_AL   %display_chars%
ALUOP_FLAGS %A%
JZ .set_star
ST      %display_chars% 0x00
RETI
.set_star
ST      %display_chars% '*'

.noirq
RETI


