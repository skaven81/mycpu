# vim: syntax=asm-mycpu

:boot_print_status
# Print the current CPU clock
CALL :sys_clock_speed
LDI_C .clockspeed_banner
CALL :heap_push_A
CALL :printf

# Print the current date and time
LDI_C .clock_banner
LD_AL %tmr_clk_sec%
CALL :heap_push_AL
LD_AL %tmr_clk_min%
CALL :heap_push_AL
LD_AL %tmr_clk_hr%
CALL :heap_push_AL
LD_AL %tmr_clk_date%
CALL :heap_push_AL
LD_AL %tmr_clk_month%
LDI_BL %tmr_clk_month_mask%
ALUOP_AL %A&B%+%AL%+%BL%
CALL :heap_push_AL
LD_AL %tmr_clk_year%
CALL :heap_push_AL
LD_AL %tmr_clk_century%
CALL :heap_push_AL
CALL :printf
RET

.clockspeed_banner "Current CPU frequency %UkHz\n\0"
.clock_banner "Current clock %B%B-%B-%B %B:%B:%B\n\0" # YYYY-MM-DD HH:MM:SS
