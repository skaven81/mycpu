# vim: syntax=asm-mycpu

:cmd_clock

# Get our first argument
LDI_D $user_input_tokens+2      # D points at first argument pointer
LDA_D_AH                        # put high byte of first arg pointer into AH
INCR_D
LDA_D_AL                        # put low byte of first arg pointer into AL
INCR_D
ALUOP_FLAGS %A%+%AH%            # check if null
JNZ .check_arg
CALL .printclock
RET

.check_arg
LDI_A $user_input_tokens+2      # Get pointer to first arg into C
LDA_A_CH                        # |
LDI_A $user_input_tokens+3      # |
LDA_A_CL                        # |
LDI_D .arg_date
CALL :strcmp                    # result in AL
ALUOP_FLAGS %A%+%AL%
JZ .just_date
LDI_D .arg_time
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .just_time
LDI_D .arg_set
CALL :strcmp
ALUOP_FLAGS %A%+%AL%
JZ .set_clock

# Nothing matched, show usage
LDI_C .usage
CALL :print
RET

#######
# If `set`, set the clock and exit
.set_clock
LDI_C .clock_prompt
CALL :print
CALL .printclock

LDI_AL 0
CALL :malloc                        # A has a pointer to a 16-byte bufer
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # copy memory address to D
PUSH_DH
PUSH_DL                             # save memory address for later

LDI_C .set_year_prompt              # Prompt for new year
LD_AL %tmr_clk_year%
CALL :heap_push_AL
LD_AL %tmr_clk_century%
CALL :heap_push_AL
CALL :printf
CALL .read_4_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_month
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
ALUOP_ADDR %A%+%AH% %tmr_clk_century%   # set the century
ALUOP_ADDR %A%+%AL% %tmr_clk_year%      # set the year

.set_month
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_month_prompt
LD_AL %tmr_clk_month%               # Load month from timer
LDI_BL %tmr_clk_month_mask%         # |
ALUOP_AL %A&B%+%AL%+%BL%            # |
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_date
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
LDI_BL %tmr_clk_month_mask%
ALUOP_AL %A&B%+%AL%+%BL%            # mask user's input to fit
ALUOP_ADDR %A%+%AL% %tmr_clk_month% # set month

.set_date
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_date_prompt
LD_AL %tmr_clk_date%                # Load date from timer
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_day
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
ALUOP_ADDR %A%+%AL% %tmr_clk_date%  # set date

.set_day
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_day_prompt
LD_AL %tmr_clk_day%                 # Load day from timer
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_hour
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
LDI_BL %tmr_clk_day_mask%
ALUOP_AL %A&B%+%AL%+%BL%            # mask user's input to fit
ALUOP_ADDR %A%+%AL% %tmr_clk_day%   # set day

.set_hour
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_hour_prompt
LD_AL %tmr_clk_hr%                  # Load hour from timer
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_min 
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
ALUOP_ADDR %A%+%AL% %tmr_clk_hr%    # set hours

.set_min
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_minute_prompt
LD_AL %tmr_clk_min%                 # Load minute from timer
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .set_sec
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
ALUOP_ADDR %A%+%AL% %tmr_clk_min%   # set minutes

.set_sec
POP_DL                              # Restore our malloc'd pointer to D
POP_DH                              # |
PUSH_DH                             # |
PUSH_DL                             # |
LDI_C .set_second_prompt
LD_AL %tmr_clk_sec%                 # Load minute from timer
CALL :heap_push_AL                  # |
CALL :printf
CALL .read_2_bcd
ALUOP_FLAGS %A%+%AL%                # AL will be zero if user didn't enter anything
JZ .finish_set
ALUOP_FLAGS %B%+%BL%                # BL contains flags
JNZ .abort_set                      # abort if bad input
ALUOP_ADDR %A%+%AL% %tmr_clk_sec%   # set seconds

.finish_set
POP_AL                              # Retrieve malloc'd address
POP_AH
LDI_BL 0                            # one block
CALL :free
RET

.abort_set
CALL :heap_push_BL
CALL :heap_push_C
LDI_C .set_error
CALL :printf
POP_AL                              # Retrieve malloc'd address
POP_AH
LDI_BL 0                            # one block
CALL :free
RET

# If `date`, just print date and exit
.just_date
CALL .printdate
LDI_AL '\n'
CALL :putchar
RET

# If `time`, just print time and exit
.just_time
CALL .printtime
LDI_AL '\n'
CALL :putchar
RET

# If called with no arguments, print date and time and exit
.printclock
CALL .printdate
LDI_AL ' '
CALL :putchar
CALL .printtime
LDI_AL '\n'
CALL :putchar
RET

# Prints the date with no newline
.printdate
LDI_C .clock_date_str
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

# Prints the time with no newline
.printtime
LDI_C .clock_time_str
LD_AL %tmr_clk_sec%
CALL :heap_push_AL
LD_AL %tmr_clk_min%
CALL :heap_push_AL
LD_AL %tmr_clk_hr%
CALL :heap_push_AL
CALL :printf
RET

.arg_date "date\0"
.arg_time "time\0"
.arg_set "set\0"
.clock_prompt "Current date and time: \0"
.clock_date_str "%B%B-%B-%B\0" # YYYY-MM-DD
.clock_time_str "%B:%B:%B\0" # HH:MM:SS
.usage "Usage: clock [date|time|set]\n\0"
.set_year_prompt "Year [%B%B]: \0"
.set_month_prompt "Month [%B]: \0"
.set_date_prompt "Date [%B]: \0"
.set_day_prompt "Day of week (1-7) [%B]: \0"
.set_hour_prompt "Hour [%B]: \0"
.set_minute_prompt "Minute [%B]: \0"
.set_second_prompt "Second [%B]: \0"
.set_error "Invalid entry %s flags %x, aborting\n\0"

# Gets a 4-digit BCD value from the user, stored
# in A, with flags in BL.  If AL is zero then the
# user entered nothing
.read_4_bcd
CALL .read_n_bcd
ALUOP_FLAGS %A%+%AL%
JZ .read_4_bcd_done
CALL :strtoi
.read_4_bcd_done
RET

# Gets a 2-digit BCD value from the user, stored
# in AL, with flags in BL.  If AL is zero then the
# user entered nothing
.read_2_bcd
CALL .read_n_bcd
ALUOP_FLAGS %A%+%AL%
JZ .read_2_bcd_done
CALL :strtoi8
.read_2_bcd_done
RET

.read_n_bcd
CALL :input                         # get user input
LDI_AL '\n'                         # input doesn't wrap to the next line,
CALL :putchar                       # so do that now
LDI_AL 0                            # left mark = 0
LDI_BL 1                            # right mark = 1
CALL :cursor_mark_getstring         # D now points at a null-terminated copy of the user's input
LDA_D_AL                            # get first char into AL
ALUOP_FLAGS %A%+%AL%                # ...is null?
JZ .read_no_input                   # ...then skip and set month
LDI_AL 'x'                          # Prepend '0x' to string in D
CALL :strprepend                    # |
LDI_AL '0'                          # |
CALL :strprepend                    # |
PUSH_DH                             # Copy D to C
POP_CH                              # |
PUSH_DL                             # |
POP_CL                              # |
.read_no_input
RET

