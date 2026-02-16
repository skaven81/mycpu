# vim: syntax=asm-mycpu

# fat16_dirent_parse: Copy a 32-byte raw directory entry into a struct,
# byte-swapping multi-byte numeric fields from little-endian to big-endian.
#
# C signature: extern void fat16_dirent_parse(struct fat16_dirent *raw, struct fat16_dirent *dest);
#
# Supports in-place parsing (raw == dest): each field is fully read before
# any writes, so byte-swap works correctly even when source and destination
# overlap.

:fat16_dirent_parse
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

CALL :heap_pop_C                # raw pointer (1st param) into C
CALL :heap_pop_D                # dest pointer (2nd param) into D

# Direct copy: bytes 0x00-0x0D (14 bytes)
# filename[8] (0x00-0x07), extension[3] (0x08-0x0A),
# attribute (0x0B), _reserved[2] (0x0C-0x0D)
MEMCPY4_C_D                     # 4 bytes (0x00-0x03)
MEMCPY4_C_D                     # 4 bytes (0x04-0x07)
MEMCPY4_C_D                     # 4 bytes (0x08-0x0B)
MEMCPY_C_D                      # 1 byte  (0x0C)
MEMCPY_C_D                      # 1 byte  (0x0D)

# Byte-swap: 7 x uint16 fields (0x0E-0x1B)
# Pattern: read 2 LE bytes from C, write in reversed order to D

# --- create_time (0x0E-0x0F) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- create_date (0x10-0x11) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- access_date (0x12-0x13) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- cluster_hi (0x14-0x15) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- write_time (0x16-0x17) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- write_date (0x18-0x19) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# --- start_cluster (0x1A-0x1B) ---
LDA_C_AL
INCR_C
LDA_C_AH
INCR_C
ALUOP_ADDR_D %A%+%AH%
INCR_D
ALUOP_ADDR_D %A%+%AL%
INCR_D

# Byte-reverse: 4-byte file_size (0x1C-0x1F)
# Read all 4 bytes from LE source, write in reversed order for BE
LDA_C_BL                       # byte0 (LSB)
INCR_C
LDA_C_BH                       # byte1
INCR_C
LDA_C_AL                       # byte2
INCR_C
LDA_C_AH                       # byte3 (MSB)
INCR_C
ALUOP_ADDR_D %A%+%AH%          # write byte3 (MSB) first
INCR_D
ALUOP_ADDR_D %A%+%AL%          # write byte2
INCR_D
ALUOP_ADDR_D %B%+%BH%          # write byte1
INCR_D
ALUOP_ADDR_D %B%+%BL%          # write byte0 (LSB) last
INCR_D

POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET
