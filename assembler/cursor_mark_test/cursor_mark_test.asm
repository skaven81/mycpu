# vim: syntax=asm-mycpu

NOP

# Clears the screen, displays a blinking cursor, which can be moved
# around the screen using the arrow keys on the keyboard.

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_clear_irq
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0xff     # char to clear screen with
LDI_AL  %red%
CALL :clear_screen

# Initialize the keyboard
CALL :keyboard_init

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Initialize the cursor at 0,0
CALL :cursor_init
CALL :cursor_display_sync

# Clear any pending KB interrupts
CALL :timer_clear_irq

# Setup our own keyboard handler
ST16    %IRQ1addr%  .irq1_kb
UMASKINT

#######
# Main loop
#######
.main_loop
JMP .main_loop
HLT

#######
# IRQ1 handler (keyboard)
#######
.irq1_kb
LD_AL   %kb_keyflags%   # clear interrupt
LDI_BL  %kb_keyflag_BREAK%
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .irq1_done          # we only care about make events

# blank out the current char location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x00
STA_D_TD

# load keystroke into AL
LD_AL   %kb_key%

.irq1_right
LDI_BL   0x1a           # right arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_left
CALL :cursor_right
JMP .irq1_done

.irq1_left
LDI_BL   0x1b           # left arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_up
CALL :cursor_left
JMP .irq1_done

.irq1_up
LDI_BL   0x18           # up arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_down
CALL :cursor_up
JMP .irq1_done

.irq1_down
LDI_BL   0x19           # down arrow
ALUOP_FLAGS %AxB%+%AL%+%BL%
JNE .irq1_number
CALL :cursor_down
JMP .irq1_done

.irq1_number
LDI_BL   '1'
ALUOP_FLAGS %A-B%+%AL%+%BL%
JO .irq1_done
LDI_BL   '9'
ALUOP_FLAGS %B-A%+%AL%+%BL%
JO .irq1_done
LDI_BL '0'
ALUOP_AL %A-B%+%AL%+%BL%    # absolute value in AL 1..9

LD_AH   %kb_keyflags%       # get flags to see if this was an F-key or regular number key
LDI_BL  %kb_keyflag_FUNCTION%
ALUOP_FLAGS %A&B%+%AH%+%BL%
JZ .save
CALL :cursor_clear_mark
JMP .irq1_done
.save
CALL :cursor_save_mark
JMP .irq1_done


.irq1_done
# write a happy face to the new location
LD_DH $crsr_addr_chars
LD_DL $crsr_addr_chars+1
LDI_TD 0x02
STA_D_TD

# save this location mark 0
LDI_AL 0
CALL :cursor_save_mark

# Display first ten mark locations

LDI_BL 9                        # start with tenth mark
.mark_render_loop
ALUOP_AL %B%+%BL%               # put the mark id in AL
CALL :cursor_get_mark           # A now contains the mark offset
LDI_BH 0x80                     # check high bit
ALUOP_FLAGS %A&B%+%AH%+%BH%     # check high bit
JZ .mark_is_valid

# undefined mark
ALUOP_PUSH %B%+%BL%
CALL :heap_push_BL
ALUOP_AH %B%+%BL%               # row (mark id) in AH
ALUOP_AL %zero%                 # col (zero) in AL
CALL :cursor_conv_rowcol        # offset now in A
LDI_B %display_chars%
CALL :add16_to_b                # B now contains address we want to write
LDI_C .fmt1
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
CALL :sprintf
POP_BL
JMP .done_rendering_mark

# defined mark
.mark_is_valid
ALUOP_PUSH %B%+%BL%
CALL :cursor_conv_addr          # AH=row, AL=col
CALL :heap_push_AL
CALL :heap_push_AH
CALL :heap_push_BL
ALUOP_AH %B%+%BL%               # row (mark id) in AH
ALUOP_AL %zero%                 # col (zero) in AL
CALL :cursor_conv_rowcol        # offset now in A
LDI_B %display_chars%
CALL :add16_to_b                # B now contains address we want to write
LDI_C .fmt2
ALUOP_DH %B%+%BH%
ALUOP_DL %B%+%BL%
CALL :sprintf
POP_BL

.done_rendering_mark
ALUOP_FLAGS %B%+%BL%
JZ .done_with_marks
ALUOP_BL %B-1%+%BL%
JMP .mark_render_loop
.done_with_marks

RETI

.fmt1 "Mark %u is undefined   \0"
.fmt2 "Mark %u row %u col %u\0"


.noirq
RETI
