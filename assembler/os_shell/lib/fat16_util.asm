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
