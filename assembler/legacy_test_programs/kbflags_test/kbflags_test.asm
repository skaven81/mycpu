# vim: syntax=asm-mycpu

NOP

# Install default IRQ handlers.
MASKINT
ST16    %IRQ0addr%  .noirq
ST16    %IRQ1addr%  :kb_irq_buf
ST16    %IRQ2addr%  .noirq
ST16    %IRQ3addr%  :timer_clear_irq
ST16    %IRQ4addr%  .noirq
ST16    %IRQ5addr%  .noirq
ST16    %IRQ6addr%  .noirq
ST16    %IRQ7addr%  .noirq

# Clear the screen
LDI_AH  0x00     # char to clear screen with
LDI_AL  %white%
CALL :clear_screen

# Initialize all the things
CALL :keyboard_init
CALL :heap_init
CALL :cursor_init
CALL :cursor_display_sync

LDI_C .fmt1

ST16    %IRQ1addr%  :kb_irq_buf
UMASKINT
.loop
CALL :kb_bufsize                # bufsize into AL
ALUOP_FLAGS %A%+%AL%
JZ .loop                        # go back to polling if buffer is empty
CALL :kb_readbuf                # buffered keyflags into AH and keystroke into AL

ALUOP_FLAGS %A%+%AL%            # Check if keystroke was null, we'll push a space instead of the null
JNZ .not_null
ALUOP_PUSH %A%+%AL%
LDI_AL ' '
CALL :heap_push_AL
POP_AL
JMP .push_rest
.not_null
CALL :heap_push_AL

.push_rest
CALL :heap_push_AL
CALL :heap_push_AH
CALL :heap_push_AH
CALL :printf
JMP .loop

.noirq
RETI

.fmt1 "Flags 0x%x [%2] Char 0x%x [%c]\n\0"
