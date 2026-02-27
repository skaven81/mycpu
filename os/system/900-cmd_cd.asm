# vim: syntax=asm-mycpu

# Change directories using fat16_pathfind as the canonical path resolver.
# Supports simple (SYS), compound (SYS/../FOO), absolute (/SYS),
# drive-prefixed (0:/SYS), and bare root (/, 0:/) paths.

:cmd_cd

VAR global word $cd_arg_ptr
VAR global word $cd_entry_ptr
VAR global word $cd_fshandle_ptr
VAR global 16 $cd_comp_buf

# Get first argument
LDI_AL 1
CALL :shell_get_argv_n          # A = argv[1] string address
ALUOP_FLAGS %A%+%AH%            # check if null
JZ .usage

# Save argument pointer for CWD update later
ALUOP_ADDR %A%+%AH% $cd_arg_ptr
ALUOP_ADDR %A%+%AL% $cd_arg_ptr+1

# Resolve the path using fat16_pathfind
CALL :heap_push_A                # push path string address
CALL :fat16_pathfind
CALL :heap_pop_A                 # A = result (dirent pointer or error code)

# Error checking: examine high byte
ALUOP_FLAGS %A%+%AH%
JZ .cd_error_notfound            # AH==0x00: not-found or syntax error
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AH%+%BL%     # E set if AH==0x01
JEQ .cd_error_ata                # AH==0x01: ATA error (AL=status)

# Success: AH >= 0x02, valid malloc address
# Save entry pointer
ALUOP_ADDR %A%+%AH% $cd_entry_ptr
ALUOP_ADDR %A%+%AL% $cd_entry_ptr+1

# Pop filesystem handle from heap
CALL :heap_pop_C                 # C = fs_handle address
ST_CH $cd_fshandle_ptr
ST_CL $cd_fshandle_ptr+1

# Verify result is a directory: check attribute at entry+0x0B
LD_AH $cd_entry_ptr
LD_AL $cd_entry_ptr+1
LDI_B 0x000b
ALUOP16O_A %ALU16_A+B%          # A = entry + 0x0B
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # D = entry + 0x0B
LDA_D_AL                        # AL = attribute byte
LDI_BL 0x10
ALUOP_FLAGS %A&B%+%AL%+%BL%     # test directory bit
JNZ .cd_is_dir

# Not a directory -- free entry and report error
LD_AH $cd_entry_ptr
LD_AL $cd_entry_ptr+1
CALL :free
LDI_C .notadir_str
CALL :print
RET

.cd_is_dir
# Extract start cluster from entry+0x1A (big-endian)
LD_AH $cd_entry_ptr
LD_AL $cd_entry_ptr+1
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%          # A = entry + 0x1A
LDA_A_BH                        # BH = cluster high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = cluster low byte
# B = target directory cluster

# Free the entry
LD_AH $cd_entry_ptr
LD_AL $cd_entry_ptr+1
CALL :free

# Store cluster in fs_handle at offset 0x36
LD_AH $cd_fshandle_ptr
LD_AL $cd_fshandle_ptr+1         # A = fs_handle base
ALUOP_PUSH %B%+%BH%             # save cluster
ALUOP_PUSH %B%+%BL%
LDI_B 0x0036
ALUOP16O_A %ALU16_A+B%          # A = fs_handle + 0x36
POP_BL                           # restore cluster
POP_BH
ALUOP_ADDR_A %B%+%BH%           # [fs_handle+0x36] = cluster_hi
ALUOP16O_A %ALU16_A+1%
ALUOP_ADDR_A %B%+%BL%           # [fs_handle+0x37] = cluster_lo

# Update $current_fs_handle_ptr to the resolved fs_handle
LD_AH $cd_fshandle_ptr
LD_AL $cd_fshandle_ptr+1
ALUOP_ADDR %A%+%AH% $current_fs_handle_ptr
ALUOP_ADDR %A%+%AL% $current_fs_handle_ptr+1

####
# Update the CWD string in the filesystem handle (offset 0x00).
# Walk the original argument, processing each component.
.cd_update_cwd
LD_CH $cd_arg_ptr
LD_CL $cd_arg_ptr+1             # C = original argument string

# Check for drive prefix: if arg[1] == ':', skip 2 chars
INCR_C
LDA_C_AL                        # AL = arg[1]
DECR_C
LDI_BL 0x3a                     # ':' = 0x3a
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .cwd_no_drive_prefix
INCR_C
INCR_C                           # skip "N:"
.cwd_no_drive_prefix

# Check if path starts with '/'
LDA_C_AL
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .cwd_component_loop          # relative path: keep CWD as-is

# Absolute path: reset CWD to "/"
INCR_C                           # advance past leading '/'
PUSH_CH
PUSH_CL
LD_DH $cd_fshandle_ptr
LD_DL $cd_fshandle_ptr+1         # D = CWD string start
LDI_AL '/'
ALUOP_ADDR_D %A%+%AL%           # CWD[0] = '/'
INCR_D
ALUOP_ADDR_D %zero%             # CWD[1] = null
POP_CL
POP_CH

####
# Process path components one at a time.
# C = current position in argument string.
.cwd_component_loop
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .cd_done                      # end of string, all done

# Copy component chars to $cd_comp_buf until '/' or null
LDI_D $cd_comp_buf
.cwd_copy_comp
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JZ .cwd_comp_end_null            # null terminator
LDI_BL '/'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .cwd_comp_end_slash
ALUOP_ADDR_D %A%+%AL%           # copy char to buffer
INCR_C
INCR_D
JMP .cwd_copy_comp

.cwd_comp_end_slash
INCR_C                           # advance past '/'
.cwd_comp_end_null
ALUOP_ADDR_D %zero%             # null-terminate the buffer

# Save continuation point
PUSH_CH
PUSH_CL

# Examine the buffered component
LDI_C $cd_comp_buf
LDA_C_AH                        # AH = comp[0]
ALUOP_FLAGS %A%+%AH%
JZ .cwd_next_comp                # empty component (double-slash) -> skip

# Check if comp[0] == '.' (0x2e)
LDI_BL 0x2e
ALUOP_FLAGS %A&B%+%AH%+%BL%
JNE .cwd_append_comp             # not a dot -> normal append

# comp[0] == '.', check comp[1]
INCR_C
LDA_C_AL                        # AL = comp[1]
ALUOP_FLAGS %A%+%AL%
JZ .cwd_next_comp                # "." alone -> skip (stay in same dir)

# comp[1] != null, check if comp[1] == '.'
ALUOP_FLAGS %A&B%+%AL%+%BL%     # BL still 0x2e
JNE .cwd_append_comp             # not ".." -> normal

# comp[0..1] == "..", check comp[2] is null
INCR_C
LDA_C_AL
ALUOP_FLAGS %A%+%AL%
JNZ .cwd_append_comp             # "..X" -> treat as normal name

# Component is ".." -> strip last directory from CWD
.cwd_strip_dir
LD_DH $cd_fshandle_ptr
LD_DL $cd_fshandle_ptr+1         # D = CWD string start
# Check if CWD is just "/" (can't go higher)
INCR_D
LDA_D_AL
DECR_D
ALUOP_FLAGS %A%+%AL%
JZ .cwd_next_comp                # CWD is "/" -> skip stripping

# Find end of CWD string
.cwd_strip_find_end
LDA_D_BL
ALUOP_FLAGS %B%+%BL%
JZ .cwd_strip_at_end
INCR_D
JMP .cwd_strip_find_end
.cwd_strip_at_end
# D at null terminator
DECR_D                           # D at trailing '/'
ALUOP_ADDR_D %zero%             # overwrite with null
LDI_BL '/'
# Erase backward until finding previous '/'
.cwd_strip_erase
DECR_D
LDA_D_AL
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is this '/'?
JEQ .cwd_next_comp               # found previous '/' -> done
ALUOP_ADDR_D %zero%             # erase character
JMP .cwd_strip_erase

.cwd_append_comp
# Uppercase the component in $cd_comp_buf in-place (FAT16 names are uppercase)
LDI_C $cd_comp_buf
LDI_D $cd_comp_buf
CALL :strupper                   # C and D end up at the null; D reloaded below
# Append component name + "/" to end of CWD
# Find end of CWD string
LD_DH $cd_fshandle_ptr
LD_DL $cd_fshandle_ptr+1         # D = CWD string start
.cwd_find_end
LDA_D_BL
ALUOP_FLAGS %B%+%BL%
JZ .cwd_at_end
INCR_D
JMP .cwd_find_end
.cwd_at_end
# D = null terminator of CWD
LDI_C $cd_comp_buf
CALL :strcpy                     # copy component to CWD end; D advances
LDI_BL '/'
ALUOP_ADDR_D %B%+%BL%           # append trailing '/'
INCR_D
ALUOP_ADDR_D %zero%             # null-terminate

.cwd_next_comp
# Restore continuation point and loop
POP_CL
POP_CH
JMP .cwd_component_loop

.cd_done
RET

####
# Error handlers

.cd_error_notfound
# AH==0x00, check AL for sub-type
ALUOP_FLAGS %A%+%AL%
JZ .cd_not_found_msg
# AL != 0: syntax error
LDI_C .syntax_err
CALL :print
RET
.cd_not_found_msg
LDI_C .notfound_str
CALL :print
RET

.cd_error_ata
LDI_C .bad_read_str
CALL :heap_push_AL
CALL :printf
RET

.usage
LDI_C .helpstr
CALL :print
RET

.helpstr "Usage: cd <directory>\n\0"
.notfound_str "Error: no such directory\n\0"
.notadir_str "Error: not a directory\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
.syntax_err "Error: unparseable path spec\n\0"
