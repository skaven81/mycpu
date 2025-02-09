# vim: syntax=asm-mycpu

# Various utility functions for manipulating the FAT16 filesystem

# Returns the currently-mounted and presently-active filesystem handle.
# Usage:
#   1. Call the function
#   2. Pop the address word
#   3. Check high byte of word for status; 0x00 = filesystem is not mounted
:fat16_get_current_fs_handle
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

LD_AL $current_drive
LDI_BL '0'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JZ .abort_not_mounted           # if the current drive was null, zero flag will be set
JNE .use_drive_1                # if result wasn't zero but they weren't the same, must be '1'
LDI_C $drive_0_fs_handle
JMP .fs_handle_addr_in_c
.use_drive_1
LDI_C $drive_1_fs_handle
.fs_handle_addr_in_c
LDA_C_AH
INCR_C
LDA_C_AL                        # filesystem handle address in A
ALUOP_CH %A%+%AH%               # copy pointer to C
ALUOP_CL %A%+%AL%               # copy pointer to C

# Check to make sure filesystem is mounted
LDI_BL '/'
LDA_C_AL                        # first byte of filesystem handle in AL
ALUOP_FLAGS %A&B%+%AL%+%BL%     # is '/'? If not, not mounted
JNE .abort_not_mounted

# If we made it here, the filesystem handle appears OK, so return it
JMP .get_current_fs_handle_done

.abort_not_mounted
LDI_C 0x0000

.get_current_fs_handle_done
CALL :heap_push_C
POP_CL
POP_CH
POP_BL
POP_AL
POP_AH
RET

# Returns the current directory cluster number. Assumes the
# filesystem handle is valid, does no verification
# Usage:
#  1. Push address of filesystem handle to heap
#  2. Call function
#  3. Pop word containing current directory cluster
:fat16_get_current_directory_cluster
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_A                # filesystem handle address in A
LDI_B 0x0036                    # Offset 0x36 = current directory cluster
CALL :add16_to_b                # B=address of current directory cluster
LDA_B_AH
CALL :incr16_b
LDA_B_AL                        # A = current directory cluster
CALL :heap_push_A

POP_BL
POP_BH
POP_AL
POP_AH
RET

