# vim: syntax=asm-mycpu

# FAT16 filesystem functions: directory entry parsing

####
# Retrieve the filename as a regular null-terminated string from a directory entry.
# To use:
#  1. Push the address word of a FAT16 directory entry
#  2. Call the function
#  3. Pop the address word of the string
#  4. Call :free to release the memory allocated for the string
:fat16_dirent_filename
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                # directory entry address in C

LDI_AL 1                        # malloc 1 block = 16 bytes
CALL :calloc_blocks             # zeroed memory address in A
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # copy memory address into D
CALL :heap_push_A               # push memory address because we need to return it

# Fetch filename: iterate through all 8 bytes
# of the filename, but don't copy the spaces
# to the destination string.
LDI_AL 8                        # AL=counter, stop for 8-char filenames
LDI_AH ' '                      # AH=space, stop for <8 char filenames
.get_filename_loop
LDA_C_BL                        # next filename character in BL
INCR_C
ALUOP_FLAGS %A&B%+%AH%+%BL%     # check if space
JEQ .get_filename_no_write
ALUOP_ADDR_D %B%+%BL%           # store character in destination string
INCR_D                          # move to next character
.get_filename_no_write
ALUOP_AL %A-1%+%AL%             # decrement counter
JNZ .get_filename_loop          # done with filename if counter is zero

.get_filename_ext
LDI_BL '.'                      # add the dot to the filename
ALUOP_ADDR_D %B%+%BL%
INCR_D

LDI_AL 3                        # AL=counter, stop for 3-char ext
.get_filename_ext_loop
LDA_C_BL                        # next ext character in BL
INCR_C
ALUOP_FLAGS %A&B%+%AH%+%BL%     # check if space
JEQ .get_filename_ext_no_write
ALUOP_ADDR_D %B%+%BL%           # store character in destination string
INCR_D                          # move to next character
.get_filename_ext_no_write
ALUOP_AL %A-1%+%AL%             # decrement counter
JNZ .get_filename_ext_loop      # done with ext if counter is zero

# Overwrite the trailing dot with a NULL if there was no filename extension
DECR_D                          # move to last character in the string
LDA_D_AL                        # load the char
LDI_BL '.'                      # check if it's a dot
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNE .get_filename_done
ALUOP_ADDR_D %zero%             # overwrite the trailing dot

.get_filename_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# Retrieve the attribute byte
# To use:
#  1. Push the address word of a FAT16 directory entry
#  2. Call the function
#  3. Pop the attribute byte
:fat16_dirent_attribute
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%

CALL :heap_pop_A                # directory entry address in A
LDI_B 0x000b                    # offset 0x0b = attribute, 1 byte
ALUOP16O_A %ALU16_A+B%                # A points at the attribute byte
LDA_A_BL                        # BL contains the attribute byte
CALL :heap_push_BL              # Push it to heap to return it

POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# Retrieve the file size as a 32-bit number (pair of words).
# The entry must be big-endian parsed (returned by fat16_dirwalk_next,
# fat16_dir_find, or fat16_dirent_parse) -- raw LE entries will give wrong results.
# To use:
#  1. Push the address word of a FAT16 directory entry (must be BE-parsed)
#  2. Call the function
#  3. Pop the low word of the size
#  4. Pop the high word of the size
:fat16_dirent_filesize
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_A                # directory entry address in A
LDI_B 0x001c                    # offset 0x1c = file size, 4 bytes (BE order)
ALUOP16O_A %ALU16_A+B%                # A points at the first byte (MSB) of the file size
LDA_A_CH                        # byte 0 -> CH (MSB of high word)
ALUOP16O_A %ALU16_A+1%
LDA_A_CL                        # byte 1 -> CL (LSB of high word)
ALUOP16O_A %ALU16_A+1%
LDA_A_DH                        # byte 2 -> DH (MSB of low word)
ALUOP16O_A %ALU16_A+1%
LDA_A_DL                        # byte 3 -> DL (LSB of low word)
CALL :heap_push_C               # push the high word onto the heap
CALL :heap_push_D               # push the low word onto the heap

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# Retrieve the starting cluster of the directory entry.
# The entry must be big-endian parsed (returned by fat16_dirwalk_next,
# fat16_dir_find, or fat16_dirent_parse) -- raw LE entries will give wrong results.
# To use:
#  1. Push the address word of a FAT16 directory entry (must be BE-parsed)
#  2. Call the function
#  3. Pop the cluster word
:fat16_dirent_cluster
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_DH
PUSH_DL

CALL :heap_pop_A                # directory entry address in A
LDI_B 0x001a                    # offset 0x1a = starting cluster, 2 bytes (BE order)
ALUOP16O_A %ALU16_A+B%                # A points at the first byte (MSB) of the cluster
LDA_A_DH                        # byte 0 -> DH (high byte)
ALUOP16O_A %ALU16_A+1%
LDA_A_DL                        # byte 1 -> DL (low byte)
CALL :heap_push_D               # push the cluster onto the heap

POP_DL
POP_DH
POP_BL
POP_BH
POP_AL
POP_AH
RET

