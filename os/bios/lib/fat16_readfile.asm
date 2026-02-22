# vim: syntax=asm-mycpu

# Function for loading a file from a FAT16 filesystem into memory,
# with optional streaming support via a caller-owned context struct.
#
# Files are loaded by sectors; the file size will be shifted right 9
# positions, plus one, to determine the number of sectors that will
# be read. This means that you must allocate memory in 512-byte chunks
# or else this function will write outside of allocated memory.
#
# Four modes of operation:
#   Mode 1 (one-shot):          n_sectors==0, state ignored. Reads entire file.
#   Mode 1b (sector-limited):   n_sectors>0, state==NULL. Reads first n_sectors
#                               sectors from dirent start; no state saved.
#   Mode 2 (init stream):       n_sectors>0, state!=NULL, flags bit 0==0.
#                               Initializes state from dirent; reads n_sectors.
#   Mode 3 (resume stream):     n_sectors>0, state!=NULL, flags bit 0==1.
#                               Resumes from saved state; reads n_sectors.
#
# Heap parameters (push order for caller):
#   1. Push filesystem handle address (word)
#   2. Push destination address (word)
#   3. Push n_sectors (word; 0 = read entire file)
#   4. Push directory entry handle (word)
#   5. Push state pointer (word; 0x0000 for one-shot)
#   6. Call :fat16_readfile
#   7. Pop status byte: 0x00 = success, >0 = ATA error
#
# After a streaming read, check state->flags & 0x02 for EOF.
:fat16_readfile
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

######
# Working globals (used during function execution)
VAR global dword $fat16_readfile_lba
VAR global word $fat16_readfile_current_cluster
VAR global word $fat16_readfile_fs_handle
VAR global word $fat16_readfile_next_write_address
VAR global byte $fat16_readfile_total_sectors_remaining
VAR global byte $fat16_readfile_sectors_remaining_in_cluster
VAR global byte $fat16_readfile_sectors_per_cluster
VAR global byte $fat16_readfile_device_id
VAR global word $fat16_readfile_state_ptr
VAR global word $fat16_readfile_n_sectors
VAR global byte $fat16_readfile_original_limit

######
# Pop parameters from heap
######
CALL :heap_pop_A                # state pointer
ALUOP_ADDR %A%+%AH% $fat16_readfile_state_ptr
ALUOP_ADDR %A%+%AL% $fat16_readfile_state_ptr+1

CALL :heap_pop_D                # directory entry address -> D
PUSH_DH
PUSH_DL                         # save dirent on hardware stack

CALL :heap_pop_A                # n_sectors (word)
ALUOP_ADDR %A%+%AH% $fat16_readfile_n_sectors
ALUOP_ADDR %A%+%AL% $fat16_readfile_n_sectors+1

CALL :heap_pop_C                # destination address
ST_CH $fat16_readfile_next_write_address
ST_CL $fat16_readfile_next_write_address+1

CALL :heap_pop_A                # filesystem handle address
ALUOP_ADDR %A%+%AH% $fat16_readfile_fs_handle
ALUOP_ADDR %A%+%AL% $fat16_readfile_fs_handle+1

######
# Extract sectors_per_cluster and device_id from fs_handle
######
LDI_B 0x003a                    # sectors per cluster offset
ALUOP16O_A %ALU16_A+B%
LDA_A_BL                        # BL = sectors_per_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_sectors_per_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_sectors_remaining_in_cluster

LD_AH $fat16_readfile_fs_handle
LD_AL $fat16_readfile_fs_handle+1
LDI_B 0x005f                    # device ID offset
ALUOP16O_A %ALU16_A+B%
LDA_A_BL
ALUOP_ADDR %B%+%BL% $fat16_readfile_device_id

######
# Mode selection: check n_sectors
######
LD_AH $fat16_readfile_n_sectors
LD_AL $fat16_readfile_n_sectors+1
ALUOP_FLAGS %A%+%AH%
JNZ .readfile_streaming_mode
ALUOP_FLAGS %A%+%AL%
JNZ .readfile_streaming_mode

######################################################
# MODE 1: One-shot read (n_sectors == 0)
# Read entire file from beginning.
######################################################
POP_DL
POP_DH                          # restore dirent address into D

# Get starting cluster from dirent (BE at offset 0x1A)
MOV_DH_AH
MOV_DL_AL                       # A = dirent base
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%          # A = dirent + 0x1A
LDA_A_BH                        # BH = cluster high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = cluster low byte
ALUOP_ADDR %B%+%BH% $fat16_readfile_current_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_current_cluster+1

# Get file size low word and compute sector count (BE at offset 0x1E)
MOV_DH_AH
MOV_DL_AL                       # A = dirent base
LDI_B 0x001e
ALUOP16O_A %ALU16_A+B%          # A = dirent + 0x1E (low word of filesize, BE)
LDA_A_BH                        # BH = filesize low word high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = filesize low word low byte
ALUOP_BH %B>>1%+%BH%            # BH = sectors (filesize >> 9, + 1)
ALUOP_BH %B+1%+%BH%
ALUOP_ADDR %B%+%BH% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %B%+%BH% $fat16_readfile_original_limit

JMP .cluster_read_loop

######################################################
# STREAMING MODE: n_sectors > 0
######################################################
.readfile_streaming_mode
# Check state pointer
LD_AH $fat16_readfile_state_ptr
LD_AL $fat16_readfile_state_ptr+1
ALUOP_FLAGS %A%+%AH%
JNZ .readfile_state_valid
ALUOP_FLAGS %A%+%AL%
JNZ .readfile_state_valid
# State is NULL but n_sectors > 0 -- treat as one-shot with sector limit
POP_DL
POP_DH                          # restore dirent
MOV_DH_AH
MOV_DL_AL                       # A = dirent base
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%          # A = dirent + 0x1A
LDA_A_BH                        # BH = cluster high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = cluster low byte
ALUOP_ADDR %B%+%BH% $fat16_readfile_current_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_current_cluster+1
LD_AL $fat16_readfile_n_sectors+1
ALUOP_ADDR %A%+%AL% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %A%+%AL% $fat16_readfile_original_limit
JMP .cluster_read_loop

.readfile_state_valid
# Load state->flags (offset 0x00)
ALUOP_DH %A%+%AH%
ALUOP_DL %A%+%AL%               # D = state pointer
LDA_D_AL                        # AL = flags byte
LDI_BL 0x01                     # bit 0 = initialized
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .readfile_resume_stream

######################################################
# MODE 2: Initial streaming read
######################################################
POP_DL
POP_DH                          # restore dirent address into D

# Get starting cluster from dirent (BE at offset 0x1A)
MOV_DH_AH
MOV_DL_AL                       # A = dirent base
LDI_B 0x001a
ALUOP16O_A %ALU16_A+B%          # A = dirent + 0x1A
LDA_A_BH                        # BH = cluster high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = cluster low byte
ALUOP_ADDR %B%+%BH% $fat16_readfile_current_cluster
ALUOP_ADDR %B%+%BL% $fat16_readfile_current_cluster+1

# Get file size low word and compute total file sectors (BE at offset 0x1E)
MOV_DH_AH
MOV_DL_AL                       # A = dirent base
LDI_B 0x001e
ALUOP16O_A %ALU16_A+B%          # A = dirent + 0x1E (low word of filesize, BE)
LDA_A_BH                        # BH = filesize low word high byte
ALUOP16O_A %ALU16_A+1%
LDA_A_BL                        # BL = filesize low word low byte
ALUOP_BH %B>>1%+%BH%            # BH = total file sectors
ALUOP_BH %B+1%+%BH%

# Save total file sectors into state->file_sectors_remaining (offset 0x0A-0x0B)
LD_DH $fat16_readfile_state_ptr
LD_DL $fat16_readfile_state_ptr+1
INCR_D                           # 0x01
INCR_D                           # 0x02
INCR_D                           # 0x03
INCR_D                           # 0x04
INCR_D                           # 0x05
INCR_D                           # 0x06
INCR_D                           # 0x07
INCR_D                           # 0x08
INCR_D                           # 0x09
INCR_D                           # 0x0A
ALUOP_ADDR_D %zero%             # file_sectors_remaining high byte = 0
INCR_D                           # 0x0B
ALUOP_ADDR_D %B%+%BH%           # file_sectors_remaining low byte = total file sectors

# Compute min(n_sectors_lo, file_sectors) for this call's limit
# n_sectors high byte nonzero means n_sectors > 255, so use file_sectors
LD_AL $fat16_readfile_n_sectors
ALUOP_FLAGS %A%+%AL%
JNZ .readfile_init_use_filesectors
# Compare low bytes
LD_AL $fat16_readfile_n_sectors+1
ALUOP_FLAGS %B-A%+%BH%+%AL%     # BH - AL: overflow if file_sectors < n_sectors
JO .readfile_init_use_filesectors
# n_sectors <= file_sectors, use n_sectors
ALUOP_ADDR %A%+%AL% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %A%+%AL% $fat16_readfile_original_limit
JMP .cluster_read_loop
.readfile_init_use_filesectors
ALUOP_ADDR %B%+%BH% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %B%+%BH% $fat16_readfile_original_limit
JMP .cluster_read_loop

######################################################
# MODE 3: Resume streaming read
######################################################
.readfile_resume_stream
POP_DL
POP_DH                          # pop and discard saved dirent (not needed for resume)

# Check EOF flag (bit 1)
LD_DH $fat16_readfile_state_ptr
LD_DL $fat16_readfile_state_ptr+1
LDA_D_AL                        # AL = flags
LDI_BL 0x02                     # bit 1 = EOF
ALUOP_FLAGS %A&B%+%AL%+%BL%
JNZ .readfile_resume_eof

# Load state fields into working globals
# D = state pointer (offset 0x00)
INCR_D                           # 0x01: device_id
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_device_id
INCR_D                           # 0x02: current_cluster high
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_current_cluster
INCR_D                           # 0x03: current_cluster low
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_current_cluster+1
INCR_D                           # 0x04: lba byte 0
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_lba
INCR_D                           # 0x05: lba byte 1
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_lba+1
INCR_D                           # 0x06: lba byte 2
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_lba+2
INCR_D                           # 0x07: lba byte 3
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_lba+3
INCR_D                           # 0x08: sectors_remaining_in_cluster
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_sectors_remaining_in_cluster
INCR_D                           # 0x09: sectors_per_cluster
LDA_D_AL
ALUOP_ADDR %A%+%AL% $fat16_readfile_sectors_per_cluster
INCR_D                           # 0x0A: file_sectors_remaining high
LDA_D_AH
INCR_D                           # 0x0B: file_sectors_remaining low
LDA_D_AL                        # A = file_sectors_remaining (word)
# Save file_sectors for epilogue computation -- push BH (high), AL (low)
# Actually we just need the low byte since files are <64K
ALUOP_BH %A%+%AL%               # BH = file_sectors_remaining low byte

# Compute min(n_sectors, file_sectors_remaining) for this call
LD_AL $fat16_readfile_n_sectors   # high byte of n_sectors
ALUOP_FLAGS %A%+%AL%
JNZ .readfile_resume_use_filesectors  # n_sectors > 255, use file_sectors
ALUOP_FLAGS %A%+%AH%
JNZ .readfile_resume_use_nsectors    # file_sectors > 255, use n_sectors

# Both <= 255, compare low bytes
LD_AL $fat16_readfile_n_sectors+1
ALUOP_FLAGS %B-A%+%BH%+%AL%     # BH - AL: overflow if file_sectors < n_sectors
JO .readfile_resume_use_filesectors
.readfile_resume_use_nsectors
LD_AL $fat16_readfile_n_sectors+1
ALUOP_ADDR %A%+%AL% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %A%+%AL% $fat16_readfile_original_limit
JMP .sector_read_loop
.readfile_resume_use_filesectors
ALUOP_ADDR %B%+%BH% $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %B%+%BH% $fat16_readfile_original_limit
JMP .sector_read_loop

.readfile_resume_eof
LDI_AL 0x00
CALL :heap_push_AL
JMP .cluster_read_done

######################################################
# Core read loop (shared by all modes)
######################################################
.cluster_read_loop
# New cluster: reset sectors_remaining_in_cluster
LD_DL $fat16_readfile_sectors_per_cluster
ST_DL $fat16_readfile_sectors_remaining_in_cluster

# Compute LBA from current cluster
LD_DH $fat16_readfile_fs_handle
LD_DL $fat16_readfile_fs_handle+1
CALL :heap_push_D               # Push fs handle
LD_DH $fat16_readfile_current_cluster
LD_DL $fat16_readfile_current_cluster+1
CALL :heap_push_D               # Push cluster number
CALL :fat16_cluster_to_lba
CALL :heap_pop_D                # low word of LBA
ST_DL $fat16_readfile_lba+3
ST_DH $fat16_readfile_lba+2
CALL :heap_pop_D                # high word of LBA
ST_DL $fat16_readfile_lba+1
ST_DH $fat16_readfile_lba+0

######
# Sector read loop
.sector_read_loop
LD_BH $fat16_readfile_total_sectors_remaining
ALUOP_FLAGS %B%+%BH%
JZ .readfile_loop_done           # exhausted our sector limit

LD_BH $fat16_readfile_sectors_remaining_in_cluster
ALUOP_FLAGS %B%+%BH%
JZ .end_sector_read_loop        # done with this cluster's sectors

# ata_read_lba(next_write_addr, lba, device_id)
LD_CH $fat16_readfile_next_write_address
LD_CL $fat16_readfile_next_write_address+1
CALL :heap_push_C
LD_DH $fat16_readfile_lba+0
LD_DL $fat16_readfile_lba+1
CALL :heap_push_D               # high word of LBA
LD_DH $fat16_readfile_lba+2
LD_DL $fat16_readfile_lba+3
CALL :heap_push_D               # low word of LBA
LD_DL $fat16_readfile_device_id
CALL :heap_push_DL
CALL :ata_read_lba
CALL :heap_pop_AL               # status byte
ALUOP_FLAGS %A%+%AL%
JNZ .abort_ata_error

# next_write_addr += 512
LD_AH $fat16_readfile_next_write_address
LD_AL $fat16_readfile_next_write_address+1
LDI_B 512
ALUOP16O_A %ALU16_A+B%
ALUOP_ADDR %A%+%AH% $fat16_readfile_next_write_address
ALUOP_ADDR %A%+%AL% $fat16_readfile_next_write_address+1

# total_sectors_remaining--
LD_AL $fat16_readfile_total_sectors_remaining
ALUOP_ADDR %A-1%+%AL% $fat16_readfile_total_sectors_remaining

# sectors_remaining_in_cluster--
LD_AL $fat16_readfile_sectors_remaining_in_cluster
ALUOP_ADDR %A-1%+%AL% $fat16_readfile_sectors_remaining_in_cluster

# lba++
LD_DH $fat16_readfile_lba+0
LD_DL $fat16_readfile_lba+1
CALL :heap_push_D
LD_DH $fat16_readfile_lba+2
LD_DL $fat16_readfile_lba+3
CALL :heap_push_D
CALL :incr32
CALL :heap_pop_D                # low word
ST_DL $fat16_readfile_lba+3
ST_DH $fat16_readfile_lba+2
CALL :heap_pop_D                # high word
ST_DL $fat16_readfile_lba+1
ST_DH $fat16_readfile_lba+0

JMP .sector_read_loop

.end_sector_read_loop
# Check if total limit reached
LD_BH $fat16_readfile_total_sectors_remaining
ALUOP_FLAGS %B%+%BH%
JZ .readfile_loop_done

# Need next cluster
LD_DH $fat16_readfile_fs_handle
LD_DL $fat16_readfile_fs_handle+1
CALL :heap_push_D
LD_DH $fat16_readfile_current_cluster
LD_DL $fat16_readfile_current_cluster+1
CALL :heap_push_D
CALL :fat16_next_cluster
CALL :heap_pop_D
ST_DL $fat16_readfile_current_cluster+1
ST_DH $fat16_readfile_current_cluster

# Loop to read sectors from next cluster.
# The sector count (total_sectors_remaining) is computed from
# min(file_sectors, n_sectors), so we will naturally exhaust
# our limit before hitting end-of-chain.
JMP .cluster_read_loop

######################################################
# Loop done -- save state if streaming
######################################################
.readfile_loop_done
# Check if we need to save state (streaming mode)
LD_AH $fat16_readfile_state_ptr
LD_AL $fat16_readfile_state_ptr+1
ALUOP_FLAGS %A%+%AH%
JNZ .readfile_check_streaming
ALUOP_FLAGS %A%+%AL%
JNZ .readfile_check_streaming
JMP .cluster_read_done_noerrors  # no state, just return success

.readfile_check_streaming
LD_BH $fat16_readfile_n_sectors
LD_BL $fat16_readfile_n_sectors+1
ALUOP_FLAGS %B%+%BH%
JNZ .readfile_do_save_state
ALUOP_FLAGS %B%+%BL%
JNZ .readfile_do_save_state
JMP .cluster_read_done_noerrors  # one-shot mode (state non-null but n_sectors=0)

.readfile_do_save_state
# Compute sectors actually read = original_limit - total_sectors_remaining
LD_AH $fat16_readfile_original_limit
LD_AL $fat16_readfile_total_sectors_remaining
ALUOP_BL %A-B%+%AH%+%AL%        # BL = sectors_read = original_limit - remaining

# Load file_sectors_remaining from state to decrement
LD_DH $fat16_readfile_state_ptr
LD_DL $fat16_readfile_state_ptr+1
PUSH_DH
PUSH_DL
INCR_D                           # 0x01
INCR_D                           # 0x02
INCR_D                           # 0x03
INCR_D                           # 0x04
INCR_D                           # 0x05
INCR_D                           # 0x06
INCR_D                           # 0x07
INCR_D                           # 0x08
INCR_D                           # 0x09
INCR_D                           # 0x0A
LDA_D_AH                        # file_sectors_remaining high byte
INCR_D
LDA_D_AL                        # file_sectors_remaining low byte
POP_DL
POP_DH                           # restore D = state base

# Subtract sectors_read from file_sectors_remaining (16-bit - 8-bit)
# file_sectors_remaining (AH:AL) -= sectors_read (BL)
LDI_BH 0x00                     # B = 0x00:sectors_read
ALUOP16O_A %ALU16_A-B%           # A = file_sectors_remaining - sectors_read
# Save updated file_sectors_remaining in BH:BL for later
ALUOP_BH %A%+%AH%
ALUOP_BL %A%+%AL%

# Determine flags byte: always set bit 0 (initialized)
LDI_AL 0x01                     # initialized
# Check for EOF conditions:
# 1. total_sectors_remaining > 0 (cluster chain ended before limit)
LD_AH $fat16_readfile_total_sectors_remaining
ALUOP_FLAGS %A%+%AH%
JNZ .readfile_set_eof            # remaining > 0 means chain ended = EOF
# 2. file_sectors_remaining == 0 (entire file has been read)
ALUOP_FLAGS %B%+%BH%
JNZ .readfile_save_state_write   # file_sectors > 255 left, not EOF
ALUOP_FLAGS %B%+%BL%
JNZ .readfile_save_state_write   # file_sectors > 0 left, not EOF
.readfile_set_eof
LDI_AL 0x03                     # initialized + EOF

.readfile_save_state_write
# D = state base pointer
# AL = flags byte
# BH:BL = updated file_sectors_remaining
# Write all state fields
ALUOP_ADDR_D %A%+%AL%           # 0x00: flags
INCR_D
LD_AL $fat16_readfile_device_id
ALUOP_ADDR_D %A%+%AL%           # 0x01: device_id
INCR_D
LD_AL $fat16_readfile_current_cluster
ALUOP_ADDR_D %A%+%AL%           # 0x02: current_cluster high
INCR_D
LD_AL $fat16_readfile_current_cluster+1
ALUOP_ADDR_D %A%+%AL%           # 0x03: current_cluster low
INCR_D
LD_AL $fat16_readfile_lba
ALUOP_ADDR_D %A%+%AL%           # 0x04: lba byte 0
INCR_D
LD_AL $fat16_readfile_lba+1
ALUOP_ADDR_D %A%+%AL%           # 0x05: lba byte 1
INCR_D
LD_AL $fat16_readfile_lba+2
ALUOP_ADDR_D %A%+%AL%           # 0x06: lba byte 2
INCR_D
LD_AL $fat16_readfile_lba+3
ALUOP_ADDR_D %A%+%AL%           # 0x07: lba byte 3
INCR_D
LD_AL $fat16_readfile_sectors_remaining_in_cluster
ALUOP_ADDR_D %A%+%AL%           # 0x08: sectors_remaining_in_cluster
INCR_D
LD_AL $fat16_readfile_sectors_per_cluster
ALUOP_ADDR_D %A%+%AL%           # 0x09: sectors_per_cluster
INCR_D
ALUOP_ADDR_D %B%+%BH%           # 0x0A: file_sectors_remaining high
INCR_D
ALUOP_ADDR_D %B%+%BL%           # 0x0B: file_sectors_remaining low

JMP .cluster_read_done_noerrors

# Return 0x00 status byte (success)
.cluster_read_done_noerrors
LDI_AL 0x00
CALL :heap_push_AL
.cluster_read_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.abort_ata_error
CALL :heap_push_AL
JMP .cluster_read_done
