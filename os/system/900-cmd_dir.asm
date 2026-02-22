# vim: syntax=asm-mycpu

# List the directory entries of the current directory

:cmd_dir

# Get current drive and a pointer to its filesystem handle
LD_AH $current_fs_handle_ptr
LD_AL $current_fs_handle_ptr+1  # A = filesystem handle
ALUOP_FLAGS %A%+%AH%
JNZ .current_fs_handle_valid
ALUOP_FLAGS %A%+%AL%
JNZ .current_fs_handle_valid
JMP .abort_not_mounted
.current_fs_handle_valid

# Retrieve directory cluster number
CALL :heap_push_A
CALL :fat16_get_current_directory_cluster
CALL :heap_pop_C                # C = current directory cluster

# Start directory walk (returns context pointer on heap)
CALL :heap_push_C               # cluster
CALL :heap_push_A               # fs_handle
CALL :fat16_dirwalk_start
CALL :heap_pop_D                # D = context pointer (or 0x00nn error)
MOV_DH_AH
ALUOP_FLAGS %A%+%AH%
JZ .start_error                 # high byte 0 = error

# Main directory entry loop
# D = dirwalk context pointer (preserved across callee-save calls)
.printdir_loop
CALL :heap_push_D               # pass context to dirwalk_next
CALL :fat16_dirwalk_next
CALL :heap_pop_A                # A = entry ptr, 0x0000=end, 0x00nn=error
ALUOP_FLAGS %A%+%AH%
JZ .loop_end                    # AH=0: end of dir or error

# Valid entry (auto-parsed to BE by dirwalk_next)
# Check volume attribute at entry + 0x0B
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%             # save entry address
LDI_B 0x000b
ALUOP16O_A %ALU16_A+B%          # A = entry + 0x0B
LDA_A_BL                        # BL = attribute byte
LDI_AL 0x08                     # volume attribute mask
ALUOP_FLAGS %A&B%+%AL%+%BL%     # test volume bit
POP_AL
POP_AH                          # A = entry address restored
JNZ .printdir_loop              # skip volume label entries

# Render and print the directory entry
CALL :heap_push_A               # address of directory entry
CALL :fat16_dirent_string       # rendered string address on heap
CALL :heap_pop_C                # C = rendered string address
MOV_CH_AH                       # Put address of dirent string into A
MOV_CL_AL
CALL :print
CALL :free                      # free the rendered string
LDI_AL '\n'
CALL :putchar
JMP .printdir_loop

.loop_end
# AH was 0. AL = 0 means end-of-dir, AL > 0 means ATA error
ALUOP_PUSH %A%+%AL%             # save potential error code
CALL :heap_push_D               # pass context
CALL :fat16_dirwalk_end          # free context and sector buffer
POP_AL
ALUOP_FLAGS %A%+%AL%
JNZ .abort_ata_error             # AL > 0 = ATA error
RET                              # clean end of directory

.start_error
MOV_DL_AL                       # AL = error code from dirwalk_start
JMP .abort_ata_error

.abort_ata_error
LDI_C .bad_read_str
CALL :heap_push_AL
CALL :printf
RET

.abort_not_mounted
LDI_C .not_mounted_str
CALL :print
RET

.not_mounted_str "Error: filesystem is not mounted\n\0"
.bad_read_str "Error: Bad read status from ATA port: 0x%x\n\0"
