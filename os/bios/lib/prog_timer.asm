# vim: syntax=asm-mycpu

###############################################
### Programmable timer (IRQ2) service functions
###############################################

###########
# Initialize the programmable timer on boot
:ptmr_init
VAR global word $ptmr_t0_handler
VAR global word $ptmr_t1_handler
VAR global word $ptmr_t2_handler
ST16 $ptmr_t0_handler :ptmr_noop_handler   # seed with no-op so the dispatcher
ST16 $ptmr_t1_handler :ptmr_noop_handler   # can CALL_D unconditionally
ST16 $ptmr_t2_handler :ptmr_noop_handler

# Set the clock select register to 1.000MHz
# for all three timers by default
VAR global byte $ptmr_clk_select
ST $ptmr_clk_select %ptmr_clk_tmr0_10M%|%ptmr_clk_tmr1_10M%|%ptmr_clk_tmr2_10M%
ST %ptmr_clk_sel%   %ptmr_clk_tmr0_10M%|%ptmr_clk_tmr1_10M%|%ptmr_clk_tmr2_10M%

# Set all three timers to idle state so they don't trigger interrupts.
# Writing a control word but then refraining from writing start counts makes
# the timer stop asserting the OUT signal and thus won't trigger IRQs
ST %ptmr_ctrl_write% %ptmr_cw_t0_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t1_mode0%
ST %ptmr_ctrl_write% %ptmr_cw_t2_mode0%

# Clear all three IRQ latches
ST %ptmr_clr_all_irq% 0x00
RET

###########
# Standard ISR for IRQ2.  Snapshots which timer(s) fired by
# reading %ptmr_irqlatch% once into AL, then walks the three
# timer bits (D7=t2, D6=t1, D5=t0) by shifting left and
# testing the overflow flag (which captures the bit shifted
# out).  For each fired timer, clears its IRQ latch and
# dispatches its handler via CALL_D.
#
# Handler pointers ($ptmr_tN_handler) must always point to
# valid code that ends with RET.  :ptmr_init seeds them to
# :ptmr_noop_handler so the dispatcher can call them
# unconditionally without a per-timer zero check.  To
# "disable" a timer's dispatch, point its handler at
# :ptmr_noop_handler -- do NOT leave the pointer at 0x0000
# (the dispatcher would CALL_D into ROM at address 0).
#
# Per-timer handlers must follow the Odyssey universal
# callee-save convention (preserve every register they
# modify, including AL).  The dispatcher relies on AL
# surviving across CALL_D since AL holds the in-progress
# walk of the latch snapshot.
#
# Saves/restores on the CPU stack (LIFO): DH, DL, AL.
# Side effects: clears the IRQ latch of each timer observed
# active in the snapshot.  Timers firing after the snapshot
# keep their latches asserted; /IRQ2 stays low and the CPU
# re-enters this ISR immediately after RETI.
#
# Cycle cost (typical "1 timer fires" path): 71 cycles
# (down from 94 in the prior FLAGS-and-zero-check version).
:ptmr_isr_std
PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

LD_AL %ptmr_irqlatch%          # snapshot all three latches

# Test t2.  Shift sets O = original bit 7 (the t2 latch bit).
ALUOP_AL %A<<1%+%AL%
JNO .ptmr_isr_check_t1
LD_TD %ptmr_clr_t2_irq%        # clear t2 latch (TD value discarded)
LD_DH $ptmr_t2_handler
LD_DL $ptmr_t2_handler+1
CALL_D

.ptmr_isr_check_t1
# Test t1.  Shift sets O = original bit 6 (the t1 latch bit).
ALUOP_AL %A<<1%+%AL%
JNO .ptmr_isr_check_t0
LD_TD %ptmr_clr_t1_irq%
LD_DH $ptmr_t1_handler
LD_DL $ptmr_t1_handler+1
CALL_D

.ptmr_isr_check_t0
# Test t0.  Shift sets O = original bit 5 (the t0 latch bit).
ALUOP_AL %A<<1%+%AL%
JNO .ptmr_isr_done
LD_TD %ptmr_clr_t0_irq%
LD_DH $ptmr_t0_handler
LD_DL $ptmr_t0_handler+1
CALL_D

.ptmr_isr_done
POP_AL
POP_DL
POP_DH
RETI

###########
# Default no-op handler.  Installed by :ptmr_init for all
# three timers so :ptmr_isr_std can dispatch unconditionally.
# Called via CALL_D; 2 cycles when invoked.
:ptmr_noop_handler
RET

###########
# Dumb timer ISR that just clears all three timer IRQ
# latches and returns.
:ptmr_isr_clearall
ST %ptmr_clr_all_irq% 0x00
RETI

###########
# Utility function for setting timer clocks
#
# Usage:
#   1. Push byte to heap: clock speed select
#      * 0 = 1.8432MHz
#      * 1 = 32.768kHz
#      * 2 = 1.000MHz
#      * 3 = system clock
#   2. Push byte to heap: timer select (0, 1, 2)
#   3. Call function
:ptmr_clk_set
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%

# Set up our field mask into AH
#  0b00000011 timer0
#  0b00001100 timer1
#  0b00110000 timer2
# And shift the clock select as well
CALL :heap_pop_BL               # timer select in BL
CALL :heap_pop_AL               # clock speed select in AL
LDI_AH 0b00000011               # AH = field mask, set to timer0 field by default
.clk_set_field_shift_loop
ALUOP_FLAGS %B%+%BL%            # do we need to shift the field mask?
JZ .clk_set_field_shift_done    # if timer select is exhausted, we're done
ALUOP_AH %A<<1%+%AH%            # shift field mask left two positions
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %A<<1%+%AL%            # shift clock select left two positions
ALUOP_AL %A<<1%+%AL%
ALUOP_BL %B-1%+%BL%             # decrement timer select
JMP .clk_set_field_shift_loop
.clk_set_field_shift_done

LD_BL $ptmr_clk_select          # load current clock settings into BL
ALUOP_BL %B&~A%+%AH%+%BL%       # clear the two bits of the field mask AH
ALUOP_BL %A|B%+%AL%+%BL%        # set the clock select bits from AL

ALUOP_ADDR %B%+%BL% %ptmr_base_clksel%  # Set the new clocks value
ALUOP_ADDR %B%+%BL% $ptmr_clk_select    # Save the new clock settings

POP_BH
POP_BL
POP_AH
POP_AL
RET

