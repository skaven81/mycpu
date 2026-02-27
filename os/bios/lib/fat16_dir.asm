# vim: syntax=asm-mycpu

# Function set for walking a FAT16 directory using context structs for reentrancy.
#
# struct fat16_dirwalk_ctx (16 bytes, 1 malloc block):
#   0x00: fs_handle ptr high byte
#   0x01: fs_handle ptr low byte
#   0x02: next_sector_lba byte 0 (MSB)
#   0x03: next_sector_lba byte 1
#   0x04: next_sector_lba byte 2
#   0x05: next_sector_lba byte 3 (LSB)
#   0x06: sector_data ptr high byte
#   0x07: sector_data ptr low byte
#   0x08: dir_idx (0xFF = before-first sentinel)
#   0x09: sectors_remaining
#   0x0A-0x0F: reserved
#
# To manually walk a directory:
#  1. Push the cluster number (or 0 for root dir)
#  2. Push the filesystem handle address
#  3. CALL :fat16_dirwalk_start
#  4. Pop the context pointer (high byte >= 0x60 = success, 0x00nn = error)
#  5. Loop:
#     5a. Push the context pointer
#     5b. CALL :fat16_dirwalk_next
#     5c. Pop the entry pointer
#         - high byte >= 0x40 = valid parsed entry (fields already big-endian)
#         - 0x0000 = end of directory
#         - 0x00nn (nn>0) = ATA error
#     5d. Process the entry
#  6. Push the context pointer
#  7. CALL :fat16_dirwalk_end (frees sector buffer + context)
#
# To seek a file or dir in a specific directory:
#  1. Push a word containing the filesystem handle
#  2. Push a word containing the cluster to search
#  3. Push the address of a string with the filename/dirname
#       (an empty string to match first qualifying entry)
#  4. Push a byte containing a mask used to filter OUT entries
#  5. Push a byte containing a mask used to filter IN entries (0xff = allow all)
#  6. CALL :fat16_dir_find
#  7. Pop the address of a 32-byte memory region that contains a copy of the
#     directory entry (already parsed to big-endian).
#     * If 0x0000, the file/dir was not found.
#     * If 0x02nn, an ATA error occurred
#  8. If found, be sure to :free the returned memory address

# Working globals -- loaded/saved from context at each dirwalk call
VAR global word $dirwalk_current_fs_handle
VAR global dword $dirwalk_next_sector_lba
VAR global word $dirwalk_current_sector_data
VAR global byte $dirwalk_current_dir_idx
VAR global byte $dirwalk_num_sectors_remaining
# Filter globals -- used only within dir_find (not part of dirwalk context)
VAR global byte $dirwalk_find_filter_out
VAR global byte $dirwalk_find_filter_in

######################################################
# fat16_dir_find: search for a file/dir by name
#
# Heap params (push order): fs_handle, cluster, name, filter_out, filter_in
# Heap return: entry_ptr (0x0000=not found, 0x02nn=ATA error)
# Returned entry is a malloc'd copy (already parsed to BE). Caller must :free.
######################################################
:fat16_dir_find
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_CL                   # filter IN mask
ST_CL $dirwalk_find_filter_in
CALL :heap_pop_CL                   # filter OUT mask
ST_CL $dirwalk_find_filter_out
CALL :heap_pop_D                    # name string to match -> D
CALL :heap_pop_C                    # cluster to search -> C
CALL :heap_pop_A                    # filesystem handle -> A

# Begin directory walk
CALL :heap_push_C                   # cluster
CALL :heap_push_A                   # filesystem handle
CALL :fat16_dirwalk_start
CALL :heap_pop_A                    # context pointer

# Check for error (high byte 0x00 = error)
ALUOP_FLAGS %A%+%AH%
JZ .dir_find_abort_ata_error_pre

# Save context pointer in C for the loop; D has the name string
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # C = context_ptr

.dir_find_loop
CALL :heap_push_C                   # push context_ptr
CALL :fat16_dirwalk_next
CALL :heap_pop_A                    # A = entry_ptr or sentinel

ALUOP_FLAGS %A%+%AH%
JZ .dir_find_check_sentinel         # high byte 0x00 = end-of-dir or error

# Valid entry (already parsed by dirwalk_next).
# Check attribute byte directly at offset 0x0B
PUSH_CH
PUSH_CL
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # C = entry address temporarily
INCR_C                               # 0x01
INCR_C                               # 0x02
INCR_C                               # 0x03
INCR_C                               # 0x04
INCR_C                               # 0x05
INCR_C                               # 0x06
INCR_C                               # 0x07
INCR_C                               # 0x08
INCR_C                               # 0x09
INCR_C                               # 0x0A
INCR_C                               # 0x0B
LDA_C_BL                            # BL = attribute byte
POP_CL
POP_CH                               # restore C = context_ptr

# IN filter: if filter_in == 0xff, skip IN test
ALUOP_PUSH %A%+%AL%
LD_AL $dirwalk_find_filter_in
LDI_BH 0xff
ALUOP_FLAGS %A&B%+%AL%+%BH%
POP_AL
JEQ .dir_find_no_in_filter

# IN filter test: if entry DOES NOT match the filter, skip it
ALUOP_PUSH %A%+%AL%
LD_AL $dirwalk_find_filter_in
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JZ .dir_find_next_entry             # skip: attrs don't match IN filter

# OUT filter test: if entry DOES match the filter, skip it
.dir_find_no_in_filter
ALUOP_PUSH %A%+%AL%
LD_AL $dirwalk_find_filter_out
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JNZ .dir_find_next_entry            # skip: attrs match OUT filter

# Get the filename of this entry and compare with target
CALL :heap_push_A                   # entry address
CALL :fat16_dirent_filename         # filename string on heap
CALL :heap_pop_B                    # B = pointer to filename string

# If the target string (D) is empty, match any entry
ALUOP_PUSH %A%+%AL%
LDA_D_AL
ALUOP_FLAGS %A%+%AL%
POP_AL
JZ .dir_find_done_match_free_name

# Compare filename (B) with target (D) via strcmp
# We need C=filename, D=target for strcmp. But C has context_ptr.
# Save C (context_ptr), put filename in C.
PUSH_CH
PUSH_CL
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%                   # C = filename string

# Save A (entry ptr) so we can use A for free
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%

MOV_CL_AL                           # Copy C to A to free
MOV_CH_AH
CALL :free                          # free the filename string
CALL :strcasecmp                    # Compare C and D case-insensitively, result in AL
ALUOP_FLAGS %A%+%AL%

POP_AL                              # restore entry ptr
POP_AH
POP_CL                              # restore context_ptr
POP_CH

JZ .dir_find_done_match

.dir_find_next_entry
JMP .dir_find_loop

.dir_find_check_sentinel
# A has 0x0000 (end of dir) or 0x00nn (ATA error)
ALUOP_FLAGS %A%+%AL%
JNZ .dir_find_abort_ata_error       # nn > 0 = ATA error
# Not found
CALL :heap_push_C                   # push context for dirwalk_end
CALL :fat16_dirwalk_end
LDI_C 0x0000
CALL :heap_push_C                   # return 0x0000 = not found
JMP .dir_find_done

.dir_find_done_match_free_name
# B has filename string to free; A has entry address
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_AH %B%+%BH%                   # copy B (filename ptr) to A for :free
ALUOP_AL %B%+%BL%
CALL :free                          # free filename string
POP_AL
POP_AH

.dir_find_done_match
# A = entry address (in sector buffer, already parsed)
# Copy to malloc'd memory, then end dirwalk
PUSH_CH
PUSH_CL                             # save context_ptr
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # C = source (entry in sector buffer)
LDI_AL 2                            # 2 blocks = 32 bytes
CALL :malloc_blocks                 # A = new memory
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = destination
PUSH_DH
PUSH_DL
LDI_AL 1                            # copy 2 blocks (32 bytes)
CALL :memcpy_blocks
POP_DL
POP_DH                              # D = copy address
POP_CL
POP_CH                              # C = context_ptr

CALL :heap_push_D                   # push copy to return
CALL :heap_push_C                   # push context for dirwalk_end
CALL :fat16_dirwalk_end
JMP .dir_find_done

.dir_find_abort_ata_error
# C = context_ptr, AL = ATA error code
CALL :heap_push_C
CALL :fat16_dirwalk_end
LDI_AH 0x02
CALL :heap_push_A                   # return 0x02nn
JMP .dir_find_done

.dir_find_abort_ata_error_pre
# Error before context was created (dirwalk_start failed)
# AL already has error code from dirwalk_start
LDI_AH 0x02
CALL :heap_push_A
JMP .dir_find_done

.dir_find_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


######################################################
# fat16_dirwalk_start: initialize directory walking
#
# Heap params (push order): cluster (word), fs_handle (word)
# Heap return: context_ptr (high byte >= 0x60 = success, 0x00nn = error)
#
# Allocates context struct (1 block) + sector buffer (4 segments).
# Reads first sector into buffer. Sets dir_idx to 0xFF (before-first).
######################################################
:fat16_dirwalk_start
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Pop filesystem handle address
CALL :heap_pop_A                    # A = fs_handle
ALUOP_ADDR %A%+%AH% $dirwalk_current_fs_handle
ALUOP_ADDR %A%+%AL% $dirwalk_current_fs_handle+1
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = fs_handle (saved for later)

# Pop cluster number
CALL :heap_pop_A                    # A = cluster
ALUOP_CH %A%+%AH%
ALUOP_CL %A%+%AL%                   # C = cluster (saved for later)

# Allocate 512 bytes for sector data
LDI_AL 4                            # 4 segments = 512 bytes
CALL :malloc_segments               # address in A
ALUOP_ADDR %A%+%AH% $dirwalk_current_sector_data
ALUOP_ADDR %A%+%AL% $dirwalk_current_sector_data+1

# Determine LBA and sector count based on cluster
MOV_CH_AH
MOV_CL_AL                           # A = cluster
ALUOP_FLAGS %A%+%AH%
JNZ .dirwalk_start_subdir
ALUOP_FLAGS %A%+%AL%
JNZ .dirwalk_start_subdir

# Cluster=0: root directory
LDI_C $dirwalk_current_fs_handle
LDA_C_AH
INCR_C
LDA_C_AL                            # A = fs_handle address
LDI_B 0x004f                        # RootDirectoryRegionStart LBA offset
ALUOP16O_B %ALU16_A+B%
ALUOP_CH %B%+%BH%
ALUOP_CL %B%+%BL%                   # C = address of root dir LBA
LDI_D $dirwalk_next_sector_lba
LDI_AL 3                            # copy 4 bytes
CALL :memcpy

LDI_C $dirwalk_current_fs_handle
LDA_C_AH
INCR_C
LDA_C_AL
LDI_B 0x0060                        # num root dir sectors (low byte at offset 0x60)
ALUOP16O_B %ALU16_A+B%
LDA_B_AL
ALUOP_ADDR %A%+%AL% $dirwalk_num_sectors_remaining

JMP .dirwalk_start_lba_done

.dirwalk_start_subdir
CALL :heap_push_D                   # fs_handle
CALL :heap_push_A                   # cluster number
CALL :fat16_cluster_to_lba
CALL :heap_pop_B                    # B = low word of LBA
CALL :heap_pop_A                    # A = high word of LBA
LDI_D $dirwalk_next_sector_lba
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D
ALUOP_ADDR_D %B%+%BH%
INCR_D
ALUOP_ADDR_D %B%+%BL%

LDI_C $dirwalk_current_fs_handle
LDA_C_AH
INCR_C
LDA_C_AL
LDI_B 0x003a                        # sectors per cluster offset
ALUOP16O_B %ALU16_A+B%
LDA_B_AL
ALUOP_ADDR %A%+%AL% $dirwalk_num_sectors_remaining

.dirwalk_start_lba_done
# Read first sector (this sets dir_idx to 0 internally)
CALL .dirwalk_read_next_sector
CALL :heap_pop_AL                   # ATA status byte
ALUOP_FLAGS %A%+%AL%
JZ .dirwalk_start_alloc_ctx

# ATA error -- save error byte, free sector buffer, return 0x00nn
ALUOP_PUSH %A%+%AL%                 # save ATA error byte before A is overwritten
LD_AH $dirwalk_current_sector_data
LD_AL $dirwalk_current_sector_data+1
CALL :free
POP_AL                              # restore ATA error byte
LDI_AH 0x00
CALL :heap_push_A                   # return 0x00nn (AH=0x00, AL=ATA error code)
JMP .dirwalk_start_return

.dirwalk_start_alloc_ctx
# Allocate context struct (1 block = 16 bytes)
LDI_AL 1
CALL :calloc_blocks                 # zeroed context in A
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%                   # D = context base

# Set dir_idx to 0xFF (before-first sentinel) so first
# dirwalk_next increments it to 0x00 and returns entry 0.
# Must be set after read_next_sector (which resets dir_idx to 0).
LDI_AL 0xff
ALUOP_ADDR %A%+%AL% $dirwalk_current_dir_idx

# Save state to context using the helper
CALL .dirwalk_save_context

# Return context pointer
CALL :heap_push_D

.dirwalk_start_return
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
# .dirwalk_read_next_sector: reads the sector in $dirwalk_next_sector_lba
# Sets $dirwalk_current_dir_idx to zero.
# Decrements $dirwalk_num_sectors_remaining.
# Increments $dirwalk_next_sector_lba.
# Returns the ATA read status byte on the heap.
.dirwalk_read_next_sector
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL

# Set offset to zero
ALUOP_ADDR %zero% $dirwalk_current_dir_idx

# Decrement sectors remaining
LD_AL $dirwalk_num_sectors_remaining
ALUOP_ADDR %A-1%+%AL% $dirwalk_num_sectors_remaining

# Load next sector into sector data buffer
LDI_C $dirwalk_current_sector_data
LDA_C_AH
INCR_C
LDA_C_AL
CALL :heap_push_A                   # destination address

LDI_C $dirwalk_next_sector_lba
LDA_C_AH
INCR_C
LDA_C_AL
CALL :heap_push_A                   # LBA high word

INCR_C
LDA_C_AH
INCR_C
LDA_C_AL
CALL :heap_push_A                   # LBA low word

LDI_C $dirwalk_current_fs_handle
LDA_C_AH
INCR_C
LDA_C_AL
LDI_B 0x005f                        # ATA device ID offset
ALUOP16O_B %ALU16_A+B%
LDA_B_AL
CALL :heap_push_AL                  # device ID

CALL :ata_read_lba                  # status byte on heap

# Increment LBA
LDI_C $dirwalk_next_sector_lba
LDA_C_AH
INCR_C
LDA_C_AL
CALL :heap_push_A                   # LBA high word

INCR_C
LDA_C_AH
INCR_C
LDA_C_AL
CALL :heap_push_A                   # LBA low word

CALL :incr32

CALL :heap_pop_A                    # low word
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+3
ALUOP_ADDR %A%+%AH% $dirwalk_next_sector_lba+2
CALL :heap_pop_A                    # high word
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+1
ALUOP_ADDR %A%+%AH% $dirwalk_next_sector_lba

POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET


######################################################
# fat16_dirwalk_next: advance to next valid directory entry
#
# Heap params: context_ptr (word)
# Heap return: entry_ptr (word)
#   - high byte >= 0x40 = valid parsed entry (fields big-endian)
#   - 0x0000 = end of directory
#   - 0x00nn (nn>0) = ATA error
#
# Automatically skips 0xE5 (deleted) entries and detects 0x00 (end).
# Auto-parses each returned entry via fat16_dirent_parse (in-place).
# IMPORTANT: The returned pointer is into the internal sector buffer;
# do NOT call :free on it. The buffer is freed by fat16_dirwalk_end.
######################################################
:fat16_dirwalk_next
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_D                    # D = context_ptr

# Load context into working globals
CALL .dirwalk_load_context

# Save context base on stack for later
PUSH_DH
PUSH_DL

.dirwalk_next_advance
# Increment dir_idx (0xFF wraps to 0x00 on first call)
LD_AL $dirwalk_current_dir_idx
ALUOP_AL %A+1%+%AL%
ALUOP_ADDR %A%+%AL% $dirwalk_current_dir_idx

# If >= 16, load next sector
LDI_BL 15
ALUOP_FLAGS %B-A%+%BL%+%AL%         # overflow means AL > 15
JNO .dirwalk_next_no_new_sector

# Need to load next sector
CALL .dirwalk_read_next_sector
CALL :heap_pop_AL                   # ATA read status byte
ALUOP_FLAGS %A%+%AL%
JZ .dirwalk_next_no_new_sector      # idx is now 0, continue

# ATA error -- save context, return error
POP_DL
POP_DH
CALL .dirwalk_save_context
LDI_AH 0x00                        # AH = 0x00 (error indicator)
CALL :heap_push_A                   # return 0x00nn
JMP .dirwalk_next_return

.dirwalk_next_no_new_sector
# Compute entry address: sector_data + (dir_idx * 32)
LDI_C $dirwalk_current_sector_data
LDA_C_AH
INCR_C
LDA_C_AL                            # A = sector_data base address
LDI_BH 0x00
LD_BL $dirwalk_current_dir_idx
ALUOP16O_B %ALU16_B<<1%             # *2
ALUOP16O_B %ALU16_B<<1%             # *4
ALUOP16O_B %ALU16_B<<1%             # *8
ALUOP16O_B %ALU16_B<<1%             # *16
ALUOP16O_B %ALU16_B<<1%             # *32
ALUOP16O_A %ALU16_A+B%              # A = entry address

# Check first byte
LDA_A_BL                            # BL = first byte of filename
ALUOP_FLAGS %B%+%BL%
JZ .dirwalk_next_end_of_dir          # 0x00 = end of directory

ALUOP_PUSH %A%+%AL%
LDI_AL 0xe5
ALUOP_FLAGS %A&B%+%AL%+%BL%
POP_AL
JEQ .dirwalk_next_advance           # 0xE5 = deleted, skip

# Valid entry -- auto-parse in place
CALL :heap_push_A                   # raw pointer (source)
CALL :heap_push_A                   # dest pointer (same = in-place)
CALL :fat16_dirent_parse

# Save context and return entry address
POP_DL
POP_DH
CALL .dirwalk_save_context
CALL :heap_push_A                   # return entry address
JMP .dirwalk_next_return

.dirwalk_next_end_of_dir
POP_DL
POP_DH
CALL .dirwalk_save_context
LDI_C 0x0000
CALL :heap_push_C                   # return 0x0000
JMP .dirwalk_next_return

.dirwalk_next_return
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
# .dirwalk_load_context: loads context struct fields into working globals
# D must point at context base address. D is preserved.
.dirwalk_load_context
ALUOP_PUSH %A%+%AL%

LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_current_fs_handle     # 0x00
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_current_fs_handle+1   # 0x01
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba       # 0x02
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+1     # 0x03
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+2     # 0x04
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_next_sector_lba+3     # 0x05
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_current_sector_data   # 0x06
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_current_sector_data+1 # 0x07
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_current_dir_idx       # 0x08
INCR_D
LDA_D_AL
ALUOP_ADDR %A%+%AL% $dirwalk_num_sectors_remaining # 0x09

# Restore D to base
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D

POP_AL
RET


####
# .dirwalk_save_context: saves working globals back to context struct
# D must point at context base address. D is preserved.
.dirwalk_save_context
ALUOP_PUSH %A%+%AL%

LD_AL $dirwalk_current_fs_handle
ALUOP_ADDR_D %A%+%AL%               # 0x00
INCR_D
LD_AL $dirwalk_current_fs_handle+1
ALUOP_ADDR_D %A%+%AL%               # 0x01
INCR_D
LD_AL $dirwalk_next_sector_lba
ALUOP_ADDR_D %A%+%AL%               # 0x02
INCR_D
LD_AL $dirwalk_next_sector_lba+1
ALUOP_ADDR_D %A%+%AL%               # 0x03
INCR_D
LD_AL $dirwalk_next_sector_lba+2
ALUOP_ADDR_D %A%+%AL%               # 0x04
INCR_D
LD_AL $dirwalk_next_sector_lba+3
ALUOP_ADDR_D %A%+%AL%               # 0x05
INCR_D
LD_AL $dirwalk_current_sector_data
ALUOP_ADDR_D %A%+%AL%               # 0x06
INCR_D
LD_AL $dirwalk_current_sector_data+1
ALUOP_ADDR_D %A%+%AL%               # 0x07
INCR_D
LD_AL $dirwalk_current_dir_idx
ALUOP_ADDR_D %A%+%AL%               # 0x08
INCR_D
LD_AL $dirwalk_num_sectors_remaining
ALUOP_ADDR_D %A%+%AL%               # 0x09

# Restore D to base
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D

POP_AL
RET


######################################################
# fat16_dirwalk_end: free sector buffer and context struct
#
# Heap params: context_ptr (word)
# Heap return: (none)
######################################################
:fat16_dirwalk_end
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
PUSH_DH
PUSH_DL

CALL :heap_pop_D                    # D = context_ptr

# Read sector_data ptr from context (offset 0x06-0x07)
INCR_D                              # 0x01
INCR_D                              # 0x02
INCR_D                              # 0x03
INCR_D                              # 0x04
INCR_D                              # 0x05
INCR_D                              # 0x06
LDA_D_AH
INCR_D                              # 0x07
LDA_D_AL                            # A = sector_data address
CALL :free                          # free the 512-byte sector buffer

# Restore D to base
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D
DECR_D

# Free context struct itself (D -> A via MOV)
MOV_DH_AH
MOV_DL_AL
CALL :free

POP_DL
POP_DH
POP_AL
POP_AH
RET
