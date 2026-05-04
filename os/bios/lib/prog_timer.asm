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
ST16 $ptmr_t0_handler 0x0000            # handler=0 => ignore IRQs
ST16 $ptmr_t1_handler 0x0000
ST16 $ptmr_t2_handler 0x0000

# Set the clock select register to 1.000MHz
# for all three timers by default
VAR global byte $ptmr_clk_select
ST $ptmr_clk_select %ptmr_clk_tmr0_10M%+%ptmr_clk_tmr1_10M%+%ptmr_clk_tmr2_10M%
ST %ptmr_clk_sel%   %ptmr_clk_tmr0_10M%+%ptmr_clk_tmr1_10M%+%ptmr_clk_tmr2_10M%

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
# Standard ISR for IRQ2. Checks which of the
# three timers triggered the interrupt, clears
# its IRQ latch, and if its handler is defined,
# calls the handler.
:ptmr_isr
PUSH_DH
PUSH_DL
ALUOP_PUSH %A%+%AL%

# Latch status of all three counters atomically.
ST %ptmr_ctrl_write% %ptmr_rb_status_all%

# Read status bytes. OUT bit (D7) indicates which timers fired.
# Clear the IRQ latch only for timers observed active.
# Timers firing after the status read will retain their latches.

LD_AL %ptmr_counter0%          # Timer 0 status byte
ALUOP_FLAGS %Amsb%+%AL%
JZ .ptmr_isr_check_t1
ST %ptmr_clr_t0_irq% 0x00      # Clear Timer 0 IRQ latch
LD_AL $ptmr_t0_handler
ALUOP_DH %A%+%AL%              # Copy high byte of t0 handler to DH, also sets Z flag if empty
JZ .ptmr_isr_check_t1
LD_DL $ptmr_t0_handler+1       # High byte was non-zero, so load low byte
CALL_D                         # and run handler

.ptmr_isr_check_t1
LD_AL %ptmr_counter1%          # Timer 1 status byte
ALUOP_FLAGS %Amsb%+%AL%
JZ .ptmr_isr_check_t2
ST %ptmr_clr_t1_irq% 0x00      # Clear Timer 1 IRQ latch
LD_AL $ptmr_t1_handler
ALUOP_DH %A%+%AL%              # Copy high byte of t1 handler to DH, also sets Z flag if empty
JZ .ptmr_isr_check_t2
LD_DL $ptmr_t1_handler+1       # High byte was non-zero, so load low byte
CALL_D                         # and run handler

.ptmr_isr_check_t2
LD_AL %ptmr_counter2%          # Timer 2 status byte
ALUOP_FLAGS %Amsb%+%AL%
JZ .ptmr_isr_done
ST %ptmr_clr_t2_irq% 0x00      # Clear Timer 2 IRQ latch
LD_AL $ptmr_t2_handler
ALUOP_DH %A%+%AL%              # Copy high byte of t2 handler to DH, also sets Z flag if empty
JZ .ptmr_isr_done
LD_DL $ptmr_t2_handler+1       # High byte was non-zero, so load low byte
CALL_D                         # and run handler

.ptmr_isr_done
# Any timer that fired after its status was read still has its
# IRQ latch set. /IRQ2 will remain asserted and the CPU re-enters
# this ISR immediately after RETI.

POP_AL
POP_DL
POP_DH
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

