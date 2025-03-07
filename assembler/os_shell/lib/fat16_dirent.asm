# vim: syntax=asm-mycpu

# FAT16 filesystem functions: directory entry parsing

####
# Retrieve the filename as a regular null-terminated string from a directory entry.
# To use:
#  1. Push the address word of a FAT16 directory entry
#  2. Call the function
#  3. Pop the address word of the string
#  4. Call :free with size 0 (16 bytes) to release the memory allocated for the string
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

LDI_AL 0                        # malloc size 0 = 16 bytes
CALL :calloc                    # zeroed memory address in A
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
CALL :add16_to_a                # A points at the attribute byte
LDA_A_BL                        # BL contains the attribute byte
CALL :heap_push_BL              # Push it to heap to return it

POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# Retrieve the file size as a 32-bit number (pair of words)
# To use:
#  1. Push the address word of a FAT16 directory entry
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
LDI_B 0x001c                    # offset 0x1c = file size, 4 bytes
CALL :add16_to_a                # A points at the first byte (LSB) of the file size
LDA_A_DL
CALL :incr16_a
LDA_A_DH
CALL :incr16_a
LDA_A_CL
CALL :incr16_a
LDA_A_CH
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
# Retrieve the starting cluster of the directory entry
# To use:
#  1. Push the address word of a FAT16 directory entry
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
LDI_B 0x001a                    # offset 0x1a = starting cluster, 2 bytes
CALL :add16_to_a                # A points at the first byte (LSB) of the cluster
LDA_A_DL
CALL :incr16_a
LDA_A_DH
CALL :heap_push_D               # push the cluster onto the heap

POP_DL
POP_DH
POP_BL
POP_BH
POP_AL
POP_AH
RET

####
# Return a string containing the date and time of the provided FAT16 timestamp
# To use:
#  1. Push the address word of the first byte of the timestamp
#  2. Call the function
#  3. Pop the address word of the string
#  4. Free the string (size 1, 32 bytes)
# Returned string will be in form YYYY-MM-DD HH:MM
.get_timestamp_string
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Timestamp format (offset 0x0e, creation; offset 0x16, last write)
# Note that due to endianness, the two words are in order but the
# bytes are reversed
# | 0x0f / 0x17   | 0x0e / 0x16   | 0x11 / 0x19   | 0x10 / 0x18   |
# |7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|7|6|5|4|3|2|1|0|
# |hour 0-23| min 0-59  |sec 0-29 | year 0-127  | 1-12  |day 1-31 |
# | 5 bits  |  6 bits   | 5 bits  |  7 bits     |4 bits | 5 bits  |
# seconds is at 2-second resolution, so must be multiplied by 2
# year is after 1980, so 2024 is 44, 1980+44=2024

# Strategy is to extract each component from the final string from
# right to left, then use sprintf to generate the string, popping
# the individual values from the heap.  That way we don't have to
# retain the values in registers, just compute them each individually.

CALL :heap_pop_C                # timestamp address in C

# minute
INCR_C                          # second byte
LDA_C_AH                        # hour/min byte in AH
ALUOP_AH %A<<1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AH %A<<1%+%AH%            # shift hour/min byte left 3 positions
DECR_C                          # first byte
LDA_C_BH                        # min/sec byte in BH
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%            # shift min/sec byte right 5 positions
ALUOP_AL %A+B%+%AH%+%BH%        # combine high and low bits into AL
ALUOP_AL %A_clrbltoptwo%+%AL%   # clear the top two bits
CALL :double_dabble_byte        # AL converted to BCD across AH+AL
CALL :heap_push_AL              # push minutes (tens and units) onto heap

# hour
INCR_C                          # second byte
LDA_C_AL                        # hour/min in AL
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%
ALUOP_AL %A>>1%+%AL%            # shift right three places to get hour
CALL :double_dabble_byte        # AL converted to BCD across AH+AL
CALL :heap_push_AL              # push hours (tens and units) onto heap

# day
INCR_C                          # third byte
LDA_C_AL                        # mon/day in AL
LDI_BL 0x1f                     # mask for lower 5 bits
ALUOP_AL %A&B%+%AL%+%BL%        # day in AL
CALL :double_dabble_byte        # AL converted to BCD across AH+AL
CALL :heap_push_AL              # push day (tens and units) onto heap

# month
LDA_C_BH                        # mon/day in BH
INCR_C                          # fourth byte
LDA_C_AH                        # year/mon in AH
LDI_BL 0x01
ALUOP_AH %A&B%+%AH%+%BL%        # only last bit is used
ALUOP_AH %A<<1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AH %A<<1%+%AH%            # shift month left 3 places
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%
ALUOP_BH %B>>1%+%BH%            # shift mon/day byte right 5 positions
ALUOP_AL %A+B%+%AH%+%BH%        # combine into AL
CALL :double_dabble_byte        # AL converted to BCD across AH+AL
CALL :heap_push_AL              # push month (tens and units) onto heap

# year
LDA_C_AL                        # year/month in AL
ALUOP_AL %A>>1%+%AL%            # shift right one position
LDI_AH 0x00
LDI_B 1980
CALL :add16_to_a                # AH now has year
CALL :heap_push_A

# allocate memory for return string
LDI_AL 1                        # malloc size 1 = 32 bytes
CALL :calloc                    # zeroed memory address in A
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # copy memory address into D

LDI_C .timestamp_fmt_str        # format string in C
CALL :sprintf

CALL :heap_push_A               # push memory address to return

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.timestamp_fmt_str "%U-%B-%B %B:%B\0"

####
# Return a null-terminated string describing the directory entry
# To use:
#  1. Push the address word of a FAT16 directory entry
#  2. Call the function
#  3. Pop the address word of the string
#  4. Call :free with size 2 (48 bytes) to release the memory allocated for the string
#
# String will be formatted as such:
#
# FILENAME EXT YYYY-MM-DD HH:MM 65535      (for files <=64K in size)
# FILENAME EXT YYYY-MM-DD HH:MM 0x00001234 (for files >64K in size)
# DIR      EXT YYYY-MM-DD HH:MM <DIR>      (for directories)
#
# The string will be null-terminated not have a trailing newline.
#
# The filename and extension will be padded with spaces to maintain column widths.
# The YYYY-MM-DD HH:MM will be the last write timestamp.
# The size will be in decimal if <= 64k, otherwise a 32-bit hexadecimal number
# For directory entries, the size will be "<DIR>"
:fat16_dirent_string
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                # directory entry address in C
MOV_CH_BH
MOV_CL_BL                       # save directory entry address in B

LDI_AL 2                        # malloc size 2 = 48 bytes
CALL :calloc                    # zeroed memory address in A
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # copy memory address into D
CALL :heap_push_A               # push memory address because we need to return it

## Filename + extension

# copy the first 8 bytes of the directory entry to the target string
MEMCPY4_C_D
MEMCPY4_C_D
# add a space to the target string
LDI_AL ' '
ALUOP_ADDR_D %A%+%AL%
INCR_D
# copy the next 3 bytes of the directory entry to the target string
MEMCPY_C_D
MEMCPY_C_D
MEMCPY_C_D

# add a space to the target string
LDI_AL ' '
ALUOP_ADDR_D %A%+%AL%
INCR_D

## modify date
LDI_A 0x0016                    # offset 0x16 = last write time
CALL :add16_to_a                # A contains address of last write time
CALL :heap_push_A
CALL .get_timestamp_string      # 32-byte string address on top of heap
CALL :heap_pop_C
CALL :heap_push_C               # save copy of timestamp string address
CALL :strcpy                    # copy string from C (timestamp) to destination string in D
CALL :heap_pop_A                # restore timestamp string address to A
ALUOP_PUSH %B%+%BL%
LDI_BL 1
CALL :free                      # free the timestamp string
POP_BL

# add a space to the target string
LDI_AL ' '
ALUOP_ADDR_D %A%+%AL%
INCR_D

## attribute byte
ALUOP_PUSH %B%+%BL%
LDI_A 0x000b                    # offset 0x0b = attribute byte
CALL :add16_to_a                # A contains address of attribute byte
LDA_A_BL                        # attribute byte in BL
LDI_AL 0x10                     # bit 4 = directory
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_BL
JZ .dirent_string_file          # process as a file (append size) if not a directory

# <DIR>
LDI_C .dirent_dir
CALL :strcpy
JMP .dirent_string_done

.dirent_string_file
CALL :heap_push_B               # push directory entry address
CALL :fat16_dirent_filesize     # file size on heap, as 2 words
CALL :heap_pop_B                # low word in B
CALL :heap_pop_A                # high word in A
ALUOP_FLAGS %A%+%AH%
JNZ .dirent_string_bigsize
ALUOP_FLAGS %A%+%AL%
JNZ .dirent_string_bigsize

# handle as <64k
CALL :heap_push_B
LDI_C .dirent_size
CALL :sprintf                   # append decimal size to string at D
JMP .dirent_string_done

# handle as >64k
.dirent_string_bigsize
CALL :heap_push_BL
CALL :heap_push_BH
CALL :heap_push_AL
CALL :heap_push_AH
LDI_C .dirent_bigsize
CALL :sprintf                   # append hex size to string at D

.dirent_string_done
# return string address is already on heap, so just return
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.dirent_size "%U\0"
.dirent_bigsize "0x%x%x%x%x\0"
.dirent_dir "<DIR>\0"
