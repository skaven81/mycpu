# vim: syntax=asm-mycpu

# Various utility functions for manipulating the FAT16 filesystem

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

######
# Returns the current drive number (0 or 1) by reading
# the $current_fs_handle pointer then extracting the ATA ID from
# the referenced filesystem handle
#
# 1. Call the function
# 2. Pop the drive number byte. Will be 0xff if no drive
#    is currently selected.
:fat16_get_current_drive_number
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

LD16_A $current_fs_handle       # A contains either $drive_0_fs_handle or $drive_1_fs_handle
ALUOP_FLAGS %A%+%AH%
JNZ .gcdn_current_fs_handle_valid
ALUOP_FLAGS %A%+%AL%
JNZ .gcdn_current_fs_handle_valid
LDI_AL 0xff                     # return 0xff since $current_fs_handle does not point at anything
CALL :heap_push_AL
JMP .gcdn_done

# If we get here then $current_fs_handle pointer in A is valid
.gcdn_current_fs_handle_valid
LDI_B 0x005f                    # Offset 5f=ATA device ID
CALL :add16_to_a                # A now points at the device ID
LDA_A_BL                        # BL contains the device ID
CALL :heap_push_BL

.gcdn_done
POP_BL
POP_BH
POP_AL
POP_AH
RET

######
# Given a path string, returns a filesystem handle referenced by
# that path. So for example `0:/FOO` would return $drive_0_fs_handle
# while `1:/FOO` would return $drive_1_fs_handle.  Relative paths
# return $current_fs_handle.
#
# To use:
#  1. Load the address of the path string into C
#  2. Call the function
#  3. Pop the filesystem handle.  If the high byte is 0x00 then
#     the string was unparseable. C will point at the beginning
#     of the path (skipping over 0: or 1: if present)
:fat16_get_fs_handle_from_path
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_C                    # C = address of path string

# If second char of C is ':' and first char is '0' or '1', this is an absolute path
LDA_C_AH                            # AH = drive letter '0' or '1'
INCR_C
LDA_C_AL                            # AL = colon
DECR_C

LDI_BL ':'                          # check for the colon first
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .gfhfp_current_drive            # no colon = current drive
LDI_BL '0'
ALUOP_FLAGS %A&B%+%AH%+%BL%         # check for '0'
JEQ .gfhfp_drive_0
LDI_BL '1'
ALUOP_FLAGS %A&B%+%AH%+%BL%         # check for '1'
JEQ .gfhfp_drive_1
JMP .gfhfp_syntax_error

.gfhfp_drive_0
LD_AH $drive_0_fs_handle
LD_AL $drive_0_fs_handle+1
INCR_C                              # Move C past `0:`
INCR_C
JMP .gfhfp_done

.gfhfp_drive_1
LD_AH $drive_1_fs_handle
LD_AL $drive_1_fs_handle+1
INCR_C                              # Move C past `1:`
INCR_C
JMP .gfhfp_done

.gfhfp_current_drive
LD_AH $current_fs_handle
LD_AL $current_fs_handle+1
JMP .gfhfp_done                     # Keep C at beginning of string

.gfhfp_syntax_error
LDI_A 0x0000

.gfhfp_done
CALL :heap_push_A
POP_BL
POP_AL
POP_AH
RET

