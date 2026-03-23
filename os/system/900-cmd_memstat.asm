CALL .__global_local_init__

.memstat_show_main_ram           # static void memstat_show_main_ram()
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_B .var_s_range_start         # Load base address of s_range_start into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $malloc_range_start        # Load base address of malloc_range_start into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_range_start
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_range_start
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_range_start
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_range_start
LDI_B .var_s_num_segs            # Load base address of s_num_segs into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $malloc_segments           # Load base address of malloc_segments into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_num_segs
LDI_B .var_s_sysody_addr         # Load base address of s_sysody_addr into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B $exec_loop_program_ptr     # Load base address of exec_loop_program_ptr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_addr
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_addr
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_addr
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_addr
LDI_B .var_s_segs16              # Load base address of s_segs16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_num_segs            # Load base address of s_num_segs into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_segs16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_segs16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_segs16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_segs16
LDI_B .var_s_segs16              # Load base address of s_segs16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short s_segs16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_segs16              # Load base address of s_segs16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_segs16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_segs16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_segs16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_segs16
LDI_B .var_s_total_bytes         # Load base address of s_total_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 7                          # Constant assignment 7 for static unsigned short s_total_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_segs16              # Load base address of s_segs16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_total_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_total_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_total_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_total_bytes
LDI_B .var_s_ledger_count        # Load base address of s_ledger_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 for static unsigned short s_ledger_count
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_segs16              # Load base address of s_segs16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_ledger_count
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_ledger_count
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_ledger_count
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_ledger_count
LDI_A 0                          # Constant assignment 0 as int
CALL :heap_push_AL               # Push page number for extpage_d_push
CALL :extpage_d_push             # Map page into D-window
LDI_B .var_s_dwin                # Load base address of s_dwin into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 53248                      # Constant assignment 0xD000 for pointer static char *s_dwin
# Cast  int const (virtual) to  char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static char *s_dwin
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static char *s_dwin
ALUOP_ADDR_B %A%+%AL%            # Store to static char *s_dwin
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static char *s_dwin
LDI_B .var_s_sysody_ls           # Load base address of s_sysody_ls into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_sysody_ls
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_ls
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_ls
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_ls
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_ls
LDI_B .var_s_sysody_le           # Load base address of s_sysody_le into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_sysody_le
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
LDI_B .var_s_sysody_bytes        # Load base address of s_sysody_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_sysody_bytes
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_bytes
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <: Save A for generating rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_total_bytes         # Load base address of s_total_bytes into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_range_start         # Load base address of s_range_start into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_sysody_addr         # Load base address of s_sysody_addr into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_4            # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_A-B%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_B 1                          # BinaryOp <: assume true
JNO .binaryop_done_5             # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_B 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_5
.binaryop_equal_4
LDI_B 0                          # BinaryOp <: operands equal: false
.binaryop_done_5
POP_AL                           # BinaryOp <: Restore A after use for rhs
POP_AH                           # BinaryOp <: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_range_start         # Load base address of s_range_start into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_sysody_addr         # Load base address of s_sysody_addr into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >=: Check for equality
JEQ .binaryop_equal_8            # BinaryOp >=: check if equal
ALUOP16O_FLAGS %ALU16_A-B%       # Unsigned BinaryOp >=: Subtract to check O flag
LDI_B 0                          # BinaryOp >=: assume true
JNO .binaryop_done_9             # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_B 1                          # BinaryOp >=: overflow, so true
JMP .binaryop_done_9
.binaryop_equal_8
LDI_B 1                          # BinaryOp >=: operands equal: true
.binaryop_done_9
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_addr         # Load base address of s_sysody_addr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_12        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_12        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_13
.binarybool_istrue_12
LDI_A 1                          # BinaryOp != was true
.binarybool_done_13
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_14       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_14       # Binary boolean format check, jump if true
JMP .binarybool_done_15          # Binary boolean format check: done
.binarybool_wastrue_14
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_15
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_16       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_16       # Binary boolean format check, jump if true
JMP .binarybool_done_17          # Binary boolean format check: done
.binarybool_wastrue_16
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_17
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_2            # Condition was true
JMP .end_if_3                    # Done with false condition
.condition_true_2                # Condition was true
LDI_B .var_s_sysody_ls           # Load base address of s_sysody_ls into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_B 4                          # Constant assignment 4 for static unsigned short s_sysody_ls
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_range_start         # Load base address of s_range_start into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_addr         # Load base address of s_sysody_addr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
CALL :shift16_a_right            # BinaryOp >> 4 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_ls
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_ls
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_ls
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_ls
LDI_B .var_s_b                   # Load base address of s_b into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
LDI_A .var_s_dwin                # Load base address of s_dwin into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_ls           # Load base address of s_sysody_ls into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
# Cast  char s_dwin_element (virtual) to  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_b
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <=: Save A for generating rhs
LDI_A 239                        # Constant assignment 0xEF as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_b                   # Load base address of s_b into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_FLAGS %A-B%+%AL%+%BL%      # Unsigned BinaryOp <=: Subtract to check E and O flags
JEQ .binaryop_equal_20           # BinaryOp <=: check if equal
LDI_BL 1                         # BinaryOp <=: assume true
JNO .binaryop_done_21            # BinaryOp <= unsigned: no overflow, so baseline assumption is correct
LDI_BL 0                         # BinaryOp <=: overflow, so false
JMP .binaryop_done_21
.binaryop_equal_20
LDI_BL 1                         # BinaryOp <=: operands equal: true
.binaryop_done_21
POP_AL                           # BinaryOp <=: Restore A after use for rhs
POP_AH                           # BinaryOp <=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >=: Subtract to check E and O flags
JEQ .binaryop_equal_24           # BinaryOp >=: check if equal
LDI_AL 0                         # BinaryOp >=: assume true
JNO .binaryop_done_25            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >=: overflow, so true
JMP .binaryop_done_25
.binaryop_equal_24
LDI_AL 1                         # BinaryOp >=: operands equal: true
.binaryop_done_25
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp && 1 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_28       # Binary boolean format check, jump if true
JMP .binarybool_done_29          # Binary boolean format check: done
.binarybool_wastrue_28
LDI_AL 1                         # Binary boolean format check, is true
.binarybool_done_29
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_18           # Condition was true
JMP .end_if_19                   # Done with false condition
.condition_true_18               # Condition was true
LDI_B .var_s_b16                 # Load base address of s_b16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_b16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_b16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
LDI_B .var_s_b16                 # Load base address of s_b16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short s_b16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b16                 # Load base address of s_b16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_b16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_b16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
LDI_B .var_s_sysody_bytes        # Load base address of s_sysody_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 7                          # Constant assignment 7 for static unsigned short s_sysody_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b16                 # Load base address of s_b16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 7 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_bytes
LDI_B .var_s_sysody_le           # Load base address of s_sysody_le into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 for static unsigned short s_sysody_le
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b16                 # Load base address of s_b16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
LDI_B .var_s_sysody_le           # Load base address of s_sysody_le into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for static unsigned short s_sysody_le
# Cast  unsigned short const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_sysody_le           # Load base address of s_sysody_le into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_ls           # Load base address of s_sysody_ls into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_sysody_le
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_sysody_le
.end_if_19                       # End If
.end_if_3                        # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_total_bytes         # Load base address of s_total_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_total_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_num_segs            # Load base address of s_num_segs into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter static unsigned char s_num_segs
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_range_start         # Load base address of s_range_start into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_range_start
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_0             # "@37Main RAM@r @17base:@36 0x%X @17segs:@36 %u @17total:@36 %U@17 B (1 char=16B)@r\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char s_in_alloc
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_in_alloc
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_total
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
LDI_B .var_s_alloc_pos           # Load base address of s_alloc_pos into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_pos
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
LDI_B .var_s_alloc_remaining     # Load base address of s_alloc_remaining into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_remaining
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
LDI_B .var_s_free_bytes          # Load base address of s_free_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_free_bytes
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_free_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_free_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_free_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_free_bytes
LDI_B .var_s_alloc_count         # Load base address of s_alloc_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_count
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_count
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_count
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_count
LDI_B .var_s_max_free            # Load base address of s_max_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_max_free
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_max_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_max_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_cur_free
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
LDI_B .var_s_last_color          # Load base address of s_last_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for static unsigned char s_last_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_last_color
LDI_B .var_s_i                   # Load base address of s_i into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_i
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_i
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_i
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_i
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_i
.for_condition_30                # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_ledger_count        # Load base address of s_ledger_count into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_i                   # Load base address of s_i into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_35           # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_36            # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_36
.binaryop_equal_35
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_36
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
JNZ .for_cond_sub_true_33        # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check for condition
JNZ .for_cond_sub_true_33        # Condition was true
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JMP .for_end_34                  # Condition was false, end loop
.for_cond_sub_true_33
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
.for_cond_true_32                # Begin for loop body
LDI_B .var_s_b                   # Load base address of s_b into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
LDI_A .var_s_dwin                # Load base address of s_dwin into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_i                   # Load base address of s_i into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
# Cast  char s_dwin_element (virtual) to  unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_b
LDI_B .var_s_is_sysody           # Load base address of s_is_sysody into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp <=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp <=: Save A for generating rhs
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_le           # Load base address of s_sysody_le into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_i                   # Load base address of s_i into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <=: Check for equality
JEQ .binaryop_equal_39           # BinaryOp <=: check if equal
ALUOP16O_FLAGS %ALU16_A-B%       # Unsigned BinaryOp <=: Subtract to check O flag
LDI_B 1                          # BinaryOp <=: assume true
JNO .binaryop_done_40            # BinaryOp <= unsigned: no overflow, so baseline assumption is correct
LDI_B 0                          # BinaryOp <=: overflow, so false
JMP .binaryop_done_40
.binaryop_equal_39
LDI_B 1                          # BinaryOp <=: operands equal: true
.binaryop_done_40
POP_AL                           # BinaryOp <=: Restore A after use for rhs
POP_AH                           # BinaryOp <=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp >=: Save A for generating rhs
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_ls           # Load base address of s_sysody_ls into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_i                   # Load base address of s_i into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >=: Check for equality
JEQ .binaryop_equal_43           # BinaryOp >=: check if equal
ALUOP16O_FLAGS %ALU16_A-B%       # Unsigned BinaryOp >=: Subtract to check O flag
LDI_B 0                          # BinaryOp >=: assume true
JNO .binaryop_done_44            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_B 1                          # BinaryOp >=: overflow, so true
JMP .binaryop_done_44
.binaryop_equal_43
LDI_B 1                          # BinaryOp >=: operands equal: true
.binaryop_done_44
POP_AL                           # BinaryOp >=: Restore A after use for rhs
POP_AH                           # BinaryOp >=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_BL 0                         # Constant assignment 0 for static unsigned char s_is_sysody
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_addr         # Load base address of s_sysody_addr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_47        # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_47        # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_48
.binarybool_istrue_47
LDI_A 1                          # BinaryOp != was true
.binarybool_done_48
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_49       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_49       # Binary boolean format check, jump if true
JMP .binarybool_done_50          # Binary boolean format check: done
.binarybool_wastrue_49
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_50
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_51       # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_51       # Binary boolean format check, jump if true
JMP .binarybool_done_52          # Binary boolean format check: done
.binarybool_wastrue_51
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_52
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_is_sysody
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0x00 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_55       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_56
.binarybool_isfalse_55
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_56
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_53           # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 255                        # Constant assignment 0xFF as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_59        # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_60
.binarybool_istrue_59
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_60
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_57           # Condition was true
LDI_B .var_s_alloc_pos           # Load base address of s_alloc_pos into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for static unsigned short s_alloc_pos
# Cast  unsigned short const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_pos           # Load base address of s_alloc_pos into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
LDI_B .var_s_is_last             # Load base address of s_is_last into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for static unsigned char s_is_last
# Cast  unsigned char const (virtual) to  unsigned short 
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_remaining     # Load base address of s_alloc_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_61       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_61       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_62
.binarybool_isfalse_61
LDI_A 0                          # BinaryOp == was false
.binarybool_done_62
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_is_last
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_last             # Load base address of s_is_last into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_63           # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_sysody           # Load base address of s_is_sysody into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_65           # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_69       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_70
.binarybool_isfalse_69
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_70
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_67           # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 178                       # Constant assignment 0xB2 for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
JMP .end_if_68                   # Done with false condition
.condition_true_67               # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 177                       # Constant assignment 0xB1 for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 4                         # Constant assignment 4 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_68                       # End If
JMP .end_if_66                   # Done with false condition
.condition_true_65               # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 249                       # Constant assignment 0xF9 for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 6                         # Constant assignment 6 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_66                       # End If
JMP .end_if_64                   # Done with false condition
.condition_true_63               # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL ']'                       # Constant assignment ']' for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_sysody           # Load base address of s_is_sysody into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_71           # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_75       # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_76
.binarybool_isfalse_75
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_76
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_73           # Condition was true
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
JMP .end_if_74                   # Done with false condition
.condition_true_73               # Condition was true
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_74                       # End If
JMP .end_if_72                   # Done with false condition
.condition_true_71               # Condition was true
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_72                       # End If
.end_if_64                       # End If
LDI_B .var_s_alloc_remaining     # Load base address of s_alloc_remaining into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for static unsigned short s_alloc_remaining
# Cast  unsigned short const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_remaining     # Load base address of s_alloc_remaining into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
JMP .end_if_58                   # Done with false condition
.condition_true_57               # Condition was true
LDI_B .var_s_is_blk              # Load base address of s_is_blk into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >=: Save B for generating rhs
LDI_BL 241                       # Constant assignment 0xF1 for static unsigned char s_is_blk
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %B-A%+%BL%+%AL%      # Unsigned BinaryOp >=: Subtract to check E and O flags
JEQ .binaryop_equal_77           # BinaryOp >=: check if equal
LDI_AL 0                         # BinaryOp >=: assume true
JNO .binaryop_done_78            # BinaryOp >= unsigned: no overflow, so baseline assumption is correct
LDI_AL 1                         # BinaryOp >=: overflow, so true
JMP .binaryop_done_78
.binaryop_equal_77
LDI_AL 1                         # BinaryOp >=: operands equal: true
.binaryop_done_78
POP_BL                           # BinaryOp >=: Restore B after use for rhs
POP_BH                           # BinaryOp >=: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_is_blk
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_blk              # Load base address of s_is_blk into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_81           # Condition was true
LDI_B .var_s_b16                 # Load base address of s_b16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_b16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_b16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
LDI_B .var_s_b16                 # Load base address of s_b16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short s_b16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b16                 # Load base address of s_b16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_b16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_b16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_b16
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 for static unsigned short s_alloc_total
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b16                 # Load base address of s_b16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 3 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
JMP .end_if_82                   # Done with false condition
.condition_true_81               # Condition was true
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 15                         # Constant assignment 0x0F for static unsigned short s_alloc_total
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_b                   # Load base address of s_b into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short s_alloc_total
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_total
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_total
.end_if_82                       # End If
LDI_B .var_s_alloc_pos           # Load base address of s_alloc_pos into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_pos
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
LDI_B .var_s_alloc_remaining     # Load base address of s_alloc_remaining into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for static unsigned short s_alloc_remaining
# Cast  unsigned short const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_remaining
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_remaining
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_sysody           # Load base address of s_is_sysody into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_83           # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_is_blk              # Load base address of s_is_blk into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_85           # Condition was true
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for static unsigned char s_in_alloc
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_in_alloc
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
JMP .end_if_86                   # Done with false condition
.condition_true_85               # Condition was true
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for static unsigned char s_in_alloc
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_in_alloc
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_86                       # End If
JMP .end_if_84                   # Done with false condition
.condition_true_83               # Condition was true
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 3                         # Constant assignment 3 for static unsigned char s_in_alloc
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_in_alloc
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 5                         # Constant assignment 5 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
.end_if_84                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
# Cast  int const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_total         # Load base address of s_alloc_total into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_89       # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_89       # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_90
.binarybool_isfalse_89
LDI_A 0                          # BinaryOp == was false
.binarybool_done_90
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_87           # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL '['                       # Constant assignment '[' for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
JMP .end_if_88                   # Done with false condition
.condition_true_87               # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 7                         # Constant assignment 0x07 for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
.end_if_88                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_max_free            # Load base address of s_max_free into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_93           # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_94            # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_94
.binaryop_equal_93
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_94
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_91           # Condition was true
JMP .end_if_92                   # Done with false condition
.condition_true_91               # Condition was true
LDI_B .var_s_max_free            # Load base address of s_max_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_max_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_max_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
.end_if_92                       # End If
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_cur_free
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
LDI_B .var_s_alloc_count         # Load base address of s_alloc_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 for static unsigned short s_alloc_count
# Cast  unsigned short const (virtual) to  unsigned short 
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_count         # Load base address of s_alloc_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_count
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_count
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_count
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_count
.end_if_58                       # End If
JMP .end_if_54                   # Done with false condition
.condition_true_53               # Condition was true
LDI_B .var_s_ch                  # Load base address of s_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 176                       # Constant assignment 0xB0 for static unsigned char s_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_ch
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char s_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_cur_color
LDI_B .var_s_in_alloc            # Load base address of s_in_alloc into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char s_in_alloc
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_in_alloc
LDI_B .var_s_alloc_pos           # Load base address of s_alloc_pos into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short s_alloc_pos
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_alloc_pos
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_alloc_pos
LDI_B .var_s_free_bytes          # Load base address of s_free_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 16                         # Constant assignment 16 for static unsigned short s_free_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_free_bytes          # Load base address of s_free_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_free_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_free_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_free_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_free_bytes
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_B 16                         # Constant assignment 16 for static unsigned short s_cur_free
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # BinaryOp + 2 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_cur_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_cur_free
.end_if_54                       # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_last_color          # Load base address of s_last_color into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_99        # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_100
.binarybool_istrue_99
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_100
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_97           # Condition was true
JMP .end_if_98                   # Done with false condition
.condition_true_97               # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_103      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_104
.binarybool_isfalse_103
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_104
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_101          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_107      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_108
.binarybool_isfalse_107
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_108
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_105          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_111      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_112
.binarybool_isfalse_111
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_112
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_109          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 3                          # Constant assignment 3 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_115      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_116
.binarybool_isfalse_115
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_116
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_113          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 4                          # Constant assignment 4 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_119      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_120
.binarybool_isfalse_119
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_120
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_117          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 5                          # Constant assignment 5 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_123      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_124
.binarybool_isfalse_123
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_124
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_121          # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_1             # "@26"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .end_if_122                  # Done with false condition
.condition_true_121              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "@36"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_122                      # End If
JMP .end_if_118                  # Done with false condition
.condition_true_117              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_3             # "@25"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_118                      # End If
JMP .end_if_114                  # Done with false condition
.condition_true_113              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_114                      # End If
JMP .end_if_110                  # Done with false condition
.condition_true_109              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_5             # "@33"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_110                      # End If
JMP .end_if_106                  # Done with false condition
.condition_true_105              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_6             # "@37"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_106                      # End If
JMP .end_if_102                  # Done with false condition
.condition_true_101              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_7             # "@31"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_102                      # End If
LDI_B .var_s_last_color          # Load base address of s_last_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_color           # Load base address of s_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char s_last_color
.end_if_98                       # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_ch                  # Load base address of s_ch into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
.for_increment_31                # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_i                   # Load base address of s_i into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_s_i                   # Load base address of s_i into B
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_i
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_i
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_i
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_i
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_30            # Next for loop iteration
.for_end_34                      # End for loop
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_8             # "@r\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
CALL :extpage_d_pop              # Restore previous D-window mapping
CALL :heap_pop_AL                # Pop restored page number into AL
LDI_AH 0x00                      # Clear AH (byte return)
ALUOP_PUSH %B%+%BH%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_max_free            # Load base address of s_max_free into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp >: Check for equality
JEQ .binaryop_equal_127          # BinaryOp >: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp >: Subtract to check O flag
LDI_A 0                          # BinaryOp >: assume true
JNO .binaryop_done_128           # BinaryOp > unsigned: no overflow, so baseline assumption is correct
LDI_A 1                          # BinaryOp >: overflow, so true
JMP .binaryop_done_128
.binaryop_equal_127
LDI_A 0                          # BinaryOp >: operands equal: false
.binaryop_done_128
POP_BL                           # BinaryOp >: Restore B after use for rhs
POP_BH                           # BinaryOp >: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_125          # Condition was true
JMP .end_if_126                  # Done with false condition
.condition_true_125              # Condition was true
LDI_B .var_s_max_free            # Load base address of s_max_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_cur_free            # Load base address of s_cur_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_max_free
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_max_free
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_max_free
.end_if_126                      # End If
LDI_B .var_s_used_bytes          # Load base address of s_used_bytes into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_free_bytes          # Load base address of s_free_bytes into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_total_bytes         # Load base address of s_total_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A-B%+%AL%+%BL% %A-B%+%AH%+%BH%+%Cin% %A-B%+%AH%+%BH% # BinaryOp - 2 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short s_used_bytes
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short s_used_bytes
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short s_used_bytes
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short s_used_bytes
CALL :memstat_sep_s
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_alloc_count         # Load base address of s_alloc_count into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_alloc_count
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_total_bytes         # Load base address of s_total_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_total_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_free_bytes          # Load base address of s_free_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_free_bytes
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_used_bytes          # Load base address of s_used_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_used_bytes
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_9             # "@17Used:@36 %U@17 B  Free:@36 %U@17 B  Total:@36 %U@17 B  Allocs:@36 %U@r\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_max_free            # Load base address of s_max_free into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_max_free
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_10            # "@17Largest free:@36 %U@17 B"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
ALUOP_PUSH %B%+%BH%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &&: Save B for generating rhs
ALUOP_PUSH %A%+%AH%              # BinaryOp !=: Save A for generating rhs
ALUOP_PUSH %A%+%AL%              # BinaryOp !=: Save A for generating rhs
LDI_A 0                          # Constant assignment 0 as int
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_s_sysody_bytes        # Load base address of s_sysody_bytes into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_133       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_133       # BinaryOp != is true
LDI_B 0                          # BinaryOp != was false
JMP .binarybool_done_134
.binarybool_istrue_133
LDI_B 1                          # BinaryOp != was true
.binarybool_done_134
POP_AL                           # BinaryOp !=: Restore A after use for rhs
POP_AH                           # BinaryOp !=: Restore A after use for rhs
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_addr         # Load base address of s_sysody_addr into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_135       # BinaryOp != is true
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp != 2 byte check equality
JNE .binarybool_istrue_135       # BinaryOp != is true
LDI_A 0                          # BinaryOp != was false
JMP .binarybool_done_136
.binarybool_istrue_135
LDI_A 1                          # BinaryOp != was true
.binarybool_done_136
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp && 2 byte
ALUOP_FLAGS %A%+%AL%             # Binary boolean format check
JNZ .binarybool_wastrue_137      # Binary boolean format check, jump if true
ALUOP_FLAGS %A%+%AH%             # Binary boolean format check
JNZ .binarybool_wastrue_137      # Binary boolean format check, jump if true
JMP .binarybool_done_138         # Binary boolean format check: done
.binarybool_wastrue_137
LDI_A 1                          # Binary boolean format check, is true
.binarybool_done_138
POP_BL                           # BinaryOp &&: Restore B after use for rhs
POP_BH                           # BinaryOp &&: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_131          # Condition was true
JMP .end_if_132                  # Done with false condition
.condition_true_131              # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_s_sysody_bytes        # Load base address of s_sysody_bytes into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short s_sysody_bytes
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_11            # "   @36SYSTEM.ODY: %U@17 B (reclaim)@r"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.end_if_132                      # End If
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_8             # "@r\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.memstat_show_main_ram_return_1
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.memstat_show_ext_ram            # static void memstat_show_ext_ram()
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_B .var_se_ext_ledger         # Load base address of se_ext_ledger into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A $extmalloc_ledger          # Load base address of extmalloc_ledger into A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned char *se_ext_ledger
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned char *se_ext_ledger
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char *se_ext_ledger
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned char *se_ext_ledger
CALL :memstat_sep_d
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_12            # "@37Extended RAM@r 256 pages x 4 KiB = 1024 KiB @17(1 char=1 page)@r\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_B .var_se_alloc_count        # Load base address of se_alloc_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char se_alloc_count
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_alloc_count
LDI_B .var_se_last_color         # Load base address of se_last_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 255                       # Constant assignment 255 for static unsigned char se_last_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_last_color
LDI_B .var_se_bit_mask           # Load base address of se_bit_mask into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 0x80 for static unsigned char se_bit_mask
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_bit_mask
LDI_B .var_se_page               # Load base address of se_page into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_A 0                          # Constant assignment 0 for static unsigned short se_page
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_page
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_page
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_page
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_page
.for_condition_140               # For loop condition check
ALUOP_PUSH %A%+%AH%              # Preserve A for loop condition
ALUOP_PUSH %A%+%AL%              # Preserve A for loop condition
ALUOP_PUSH %B%+%BH%              # BinaryOp <: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <: Save B for generating rhs
LDI_B 256                        # Constant assignment 256 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_page               # Load base address of se_page into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16E_FLAGS %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% %A&B%+%AL%+%BL% # Unsigned BinaryOp <: Check for equality
JEQ .binaryop_equal_145          # BinaryOp <: check if equal
ALUOP16O_FLAGS %ALU16_B-A%       # Unsigned BinaryOp <: Subtract to check O flag
LDI_A 1                          # BinaryOp <: assume true
JNO .binaryop_done_146           # BinaryOp < unsigned: no overflow, so baseline assumption is correct
LDI_A 0                          # BinaryOp <: overflow, so false
JMP .binaryop_done_146
.binaryop_equal_145
LDI_A 0                          # BinaryOp <: operands equal: false
.binaryop_done_146
POP_BL                           # BinaryOp <: Restore B after use for rhs
POP_BH                           # BinaryOp <: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check for condition
JNZ .for_cond_sub_true_143       # Condition was true
ALUOP_FLAGS %A%+%AH%             # Check for condition
JNZ .for_cond_sub_true_143       # Condition was true
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
JMP .for_end_144                 # Condition was false, end loop
.for_cond_sub_true_143
POP_AL                           # Restore A from for loop condition
POP_AH                           # Restore A from for loop condition
.for_cond_true_142               # Begin for loop body
LDI_B .var_se_byte_idx           # Load base address of se_byte_idx into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 3                         # Constant assignment 3 for static unsigned char se_byte_idx
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_page               # Load base address of se_page into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_BH 0x00                      # Sign extend BL: unsigned value in BL
CALL :shift16_a_right            # BinaryOp >> 3 positions
CALL :shift16_a_right            # BinaryOp >> 3 positions
CALL :shift16_a_right            # BinaryOp >> 3 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
# Cast static unsigned short se_page to static unsigned char 
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_byte_idx
LDI_B .var_se_allocated          # Load base address of se_allocated into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_se_bit_mask           # Load base address of se_bit_mask into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef B backup
ALUOP_PUSH %B%+%BL%              # ArrayRef B backup
ALUOP_PUSH %A%+%AL%              # Save A while we load pointer
ALUOP_PUSH %A%+%AH%              # Save A while we load pointer
LDI_A .var_se_ext_ledger         # Load base address of se_ext_ledger into A
LDA_A_BH                         # Dereferenced load
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # Dereferenced load
LDA_A_BL                         # Dereferenced load
ALUOP16O_A %A-1%+%AL% %A-1%+%AH% %A%+%AH% # Dereferenced load
POP_AH                           # Restore A, pointer value in B
POP_AL                           # Restore A, pointer value in B
ALUOP_PUSH %B%+%BH%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # ArrayRef Save base address in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_byte_idx           # Load base address of se_byte_idx into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
LDI_AH 0x00                      # Sign extend AL: unsigned value in AL
POP_BL                           # ArrayRef Restore base address in B
POP_BH                           # ArrayRef Restore base address in B
ALUOP16O_B %A+B%+%AL%+%BL% %A+B%+%AH%+%BH%+%Cin% %A+B%+%AH%+%BH% # Add array offset in A to address reg B, element size 1
LDA_B_AL                         # Dereferenced load
POP_BL                           # ArrayRef Restore B
POP_BH                           # ArrayRef Restore B
ALUOP_AL %A&B%+%AL%+%BL%         # BinaryOp & 1 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_allocated
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_page               # Load base address of se_page into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_151      # BinaryOp == is false
ALUOP_FLAGS %A&B%+%AH%+%BH%      # BinaryOp == 2 byte check equality
JNE .binarybool_isfalse_151      # BinaryOp == is false
LDI_A 1                          # BinaryOp == was true
JMP .binarybool_done_152
.binarybool_isfalse_151
LDI_A 0                          # BinaryOp == was false
.binarybool_done_152
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP16Z_FLAGS %A%+%AL% %A%+%AH% %A%+%AL% # Check if condition
JNZ .condition_true_149          # Condition was true
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_allocated          # Load base address of se_allocated into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_153          # Condition was true
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for static unsigned char se_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_cur_color
LDI_B .var_se_ch                 # Load base address of se_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 176                       # Constant assignment 0xB0 for static unsigned char se_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_ch
JMP .end_if_154                  # Done with false condition
.condition_true_153              # Condition was true
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for static unsigned char se_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_cur_color
LDI_B .var_se_ch                 # Load base address of se_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 219                       # Constant assignment 0xDB for static unsigned char se_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_ch
LDI_B .var_se_alloc_count        # Load base address of se_alloc_count into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp +: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp +: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for static unsigned char se_alloc_count
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_alloc_count        # Load base address of se_alloc_count into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A+B%+%AL%+%BL%         # BinaryOp + 1 byte
POP_BL                           # BinaryOp +: Restore B after use for rhs
POP_BH                           # BinaryOp +: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_alloc_count
.end_if_154                      # End If
JMP .end_if_150                  # Done with false condition
.condition_true_149              # Condition was true
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 2                         # Constant assignment 2 for static unsigned char se_cur_color
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_cur_color
LDI_B .var_se_ch                 # Load base address of se_ch into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 178                       # Constant assignment 0xB2 for static unsigned char se_ch
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_ch
.end_if_150                      # End If
ALUOP_PUSH %B%+%BH%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp !=: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_se_last_color         # Load base address of se_last_color into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp != 1 byte check equality
JNE .binarybool_istrue_157       # BinaryOp != is true
LDI_AL 0                         # BinaryOp != was false
JMP .binarybool_done_158
.binarybool_istrue_157
LDI_AL 1                         # BinaryOp != was true
.binarybool_done_158
POP_BL                           # BinaryOp !=: Restore B after use for rhs
POP_BH                           # BinaryOp !=: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_155          # Condition was true
JMP .end_if_156                  # Done with false condition
.condition_true_155              # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_161      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_162
.binarybool_isfalse_161
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_162
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_159          # Condition was true
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 1                          # Constant assignment 1 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_165      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_166
.binarybool_isfalse_165
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_166
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_163          # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_13            # "@34"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
JMP .end_if_164                  # Done with false condition
.condition_true_163              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_164                      # End If
JMP .end_if_160                  # Done with false condition
.condition_true_159              # Condition was true
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_7             # "@31"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.end_if_160                      # End If
LDI_B .var_se_last_color         # Load base address of se_last_color into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cur_color          # Load base address of se_cur_color into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_last_color
.end_if_156                      # End If
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_ch                 # Load base address of se_ch into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
LDI_B .var_se_bit_mask           # Load base address of se_bit_mask into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp >>: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp >>: Save B for generating rhs
LDI_BL 1                         # Constant assignment 1 for static unsigned char se_bit_mask
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_bit_mask           # Load base address of se_bit_mask into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_AL %A>>1%+%AL%             # BinaryOp >> 1 positions
POP_BL                           # BinaryOp >>: Restore B after use for rhs
POP_BH                           # BinaryOp >>: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_bit_mask
ALUOP_PUSH %B%+%BH%              # BinaryOp ==: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp ==: Save B for generating rhs
LDI_B 0                          # Constant assignment 0 as int
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_bit_mask           # Load base address of se_bit_mask into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP_FLAGS %A&B%+%AL%+%BL%      # BinaryOp == 1 byte check equality
JNE .binarybool_isfalse_169      # BinaryOp == is false
LDI_AL 1                         # BinaryOp == was true
JMP .binarybool_done_170
.binarybool_isfalse_169
LDI_AL 0                         # BinaryOp == was false
.binarybool_done_170
POP_BL                           # BinaryOp ==: Restore B after use for rhs
POP_BH                           # BinaryOp ==: Restore B after use for rhs
ALUOP_FLAGS %A%+%AL%             # Check if condition
JNZ .condition_true_167          # Condition was true
JMP .end_if_168                  # Done with false condition
.condition_true_167              # Condition was true
LDI_B .var_se_bit_mask           # Load base address of se_bit_mask into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 128                       # Constant assignment 0x80 for static unsigned char se_bit_mask
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_bit_mask
.end_if_168                      # End If
.for_increment_141               # Begin for loop increment
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_page               # Load base address of se_page into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A+1%+%AL% %A+1%+%AH% %A%+%AH% # UnaryOp p++: increment 1-byte value
ALUOP_PUSH %B%+%BH%              # UnaryOp p++: Save B before generating lvalue
ALUOP_PUSH %B%+%BL%              # UnaryOp p++: Save B before generating lvalue
LDI_B .var_se_page               # Load base address of se_page into B
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_page
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_page
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_page
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_page
POP_BL                           # UnaryOp p++: Restore B, return rvalue in A
POP_BH                           # UnaryOp p++: Restore B, return rvalue in A
JMP .for_condition_140           # Next for loop iteration
.for_end_144                     # End for loop
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_8             # "@r\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_B .var_se_ext_free           # Load base address of se_ext_free into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp -: Save B for generating rhs
ALUOP_PUSH %A%+%AL%              # Save A while we load value
ALUOP_PUSH %A%+%AH%              # Save A while we load value
LDI_A .var_se_alloc_count        # Load base address of se_alloc_count into A
LDA_A_BL                         # Dereferenced load
POP_AH                           # Restore A, value in B
POP_AL                           # Restore A, value in B
LDI_AL 255                       # Constant assignment 255 for static unsigned char se_ext_free
ALUOP_AL %A-B%+%AL%+%BL%         # BinaryOp - 1 byte
POP_BL                           # BinaryOp -: Restore B after use for rhs
POP_BH                           # BinaryOp -: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned char se_ext_free
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_alloc_count        # Load base address of se_alloc_count into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short se_cnt16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
LDI_B .var_se_alloc_kib          # Load base address of se_alloc_kib into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 for static unsigned short se_alloc_kib
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 2 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 2 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_alloc_kib
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_alloc_kib
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_alloc_kib
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_alloc_kib
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_ext_free           # Load base address of se_ext_free into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp &: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp &: Save B for generating rhs
LDI_B 255                        # Constant assignment 0x00FF for static unsigned short se_cnt16
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16_A %A&B%+%AL%+%BL% %A&B%+%AH%+%BH% # BinaryOp & 2 byte
POP_BL                           # BinaryOp &: Restore B after use for rhs
POP_BH                           # BinaryOp &: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_cnt16
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_cnt16
LDI_B .var_se_free_kib           # Load base address of se_free_kib into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BH%              # BinaryOp <<: Save B for generating rhs
ALUOP_PUSH %B%+%BL%              # BinaryOp <<: Save B for generating rhs
LDI_B 2                          # Constant assignment 2 for static unsigned short se_free_kib
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_cnt16              # Load base address of se_cnt16 into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 2 positions
ALUOP16O_A %A<<1%+%AL% %A<<1%+%AH%+%Cin% %A<<1%+%AH% # BinaryOp << 2 positions
POP_BL                           # BinaryOp <<: Restore B after use for rhs
POP_BH                           # BinaryOp <<: Restore B after use for rhs
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AH%            # Store to static unsigned short se_free_kib
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Store to static unsigned short se_free_kib
ALUOP_ADDR_B %A%+%AL%            # Store to static unsigned short se_free_kib
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Store to static unsigned short se_free_kib
CALL :memstat_sep_s
# function returns nothing, not popping a return value
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_free_kib           # Load base address of se_free_kib into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short se_free_kib
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_ext_free           # Load base address of se_ext_free into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter static unsigned char se_ext_free
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_alloc_kib          # Load base address of se_alloc_kib into B
LDA_B_AH                         # Dereferenced load
ALUOP16O_B %B+1%+%BL% %B+1%+%BH% %B%+%BH% # Dereferenced load
LDA_B_AL                         # Dereferenced load
ALUOP16O_B %B-1%+%BL% %B-1%+%BH% %B%+%BH% # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_A                # Push parameter static unsigned short se_alloc_kib
ALUOP_PUSH %B%+%BL%              # Save B while we load value
ALUOP_PUSH %B%+%BH%              # Save B while we load value
LDI_B .var_se_alloc_count        # Load base address of se_alloc_count into B
LDA_B_AL                         # Dereferenced load
POP_BH                           # Restore B, value in A
POP_BL                           # Restore B, value in A
CALL :heap_push_AL               # Push parameter static unsigned char se_alloc_count
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_14            # "@17Alloc:@36 %u@17 pg (%U@17 KiB)  Free:@36 %u@17 pg (%U@17 KiB)  Zero-pg:@34 1@r\n"
CALL :printf
POP_CL                           # Restore C after printf
POP_CH                           # Restore C after printf
.memstat_show_ext_ram_return_139
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.memstat_show_legend             # static void memstat_show_legend()
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
CALL :memstat_sep_d
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_15            # "@37Legend (main):@r  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_6             # "@37"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL '['                       # Constant assignment '[' for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_5             # "@33"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 178                       # Constant assignment 0xB2 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_6             # "@37"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL ']'                       # Constant assignment ']' for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_16            # "@r=seg  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL '['                       # Constant assignment '[' for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_3             # "@25"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 177                       # Constant assignment 0xB1 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL ']'                       # Constant assignment ']' for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_17            # "@r=blk  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 7                         # Constant assignment 0x07 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_18            # "@r=1blk  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_2             # "@36"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 249                       # Constant assignment 0xF9 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_19            # "@r=sys  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_7             # "@31"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 176                       # Constant assignment 0xB0 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_20            # "@r=free\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_21            # "@37Legend (ext):@r   "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_4             # "@35"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 219                       # Constant assignment 0xDB for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_22            # "@r=ext-alloc  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_13            # "@34"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 178                       # Constant assignment 0xB2 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_23            # "@r=zero-pg  "
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_7             # "@31"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
LDI_AL 176                       # Constant assignment 0xB0 for  unsigned char c
CALL :heap_push_AL               # Push parameter  unsigned char c
CALL :emit_ch
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_20            # "@r=free\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
.memstat_show_legend_return_171
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

:cmd_memstat                     # void cmd_memstat()
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %B%+%BL%
ALUOP_PUSH %B%+%BH%
PUSH_CL
PUSH_CH
PUSH_DL
PUSH_DH
LD_DH $heap_ptr                  # Set frame pointer
LD_DL $heap_ptr+1                # Set frame pointer
LDI_B $term_color_enabled        # Load base address of term_color_enabled into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 1                         # Constant assignment 1 for extern unsigned char term_color_enabled
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char term_color_enabled
CALL :memstat_sep_d
# function returns nothing, not popping a return value
PUSH_CH                          # Save C before printf
PUSH_CL                          # Save C before printf
LDI_C .data_string_24            # "@37     Wire Wrap Odyssey -- Memory Status@r\n"
CALL :print
POP_CL                           # Restore C after print
POP_CH                           # Restore C after print
CALL :memstat_sep_d
# function returns nothing, not popping a return value
CALL .memstat_show_main_ram
# function returns nothing, not popping a return value
CALL .memstat_show_ext_ram
# function returns nothing, not popping a return value
CALL .memstat_show_legend
# function returns nothing, not popping a return value
CALL :memstat_sep_d
# function returns nothing, not popping a return value
LDI_B $term_color_enabled        # Load base address of term_color_enabled into B
ALUOP_PUSH %B%+%BH%              # Save lvalue address in case rvalue generation clobbers B
ALUOP_PUSH %B%+%BL%              # Save lvalue address in case rvalue generation clobbers B
LDI_AL 0                         # Constant assignment 0 for extern unsigned char term_color_enabled
POP_BL                           # Restore lvalue address
POP_BH                           # Restore lvalue address
ALUOP_ADDR_B %A%+%AL%            # Store to extern unsigned char term_color_enabled
.cmd_memstat_return_172
POP_DH
POP_DL
POP_CH
POP_CL
POP_BH
POP_BL
POP_AH
POP_AL
RET

.__global_local_init__
RET
.data_string_0 "@37Main RAM@r @17base:@36 0x%X @17segs:@36 %u @17total:@36 %U@17 B (1 char=16B)@r\n\0"
.data_string_1 "@26\0"
.data_string_2 "@36\0"
.data_string_3 "@25\0"
.data_string_4 "@35\0"
.data_string_5 "@33\0"
.data_string_6 "@37\0"
.data_string_7 "@31\0"
.data_string_8 "@r\n\0"
.data_string_9 "@17Used:@36 %U@17 B  Free:@36 %U@17 B  Total:@36 %U@17 B  Allocs:@36 %U@r\n\0"
.data_string_10 "@17Largest free:@36 %U@17 B\0"
.data_string_11 "   @36SYSTEM.ODY: %U@17 B (reclaim)@r\0"
.data_string_12 "@37Extended RAM@r 256 pages x 4 KiB = 1024 KiB @17(1 char=1 page)@r\n\0"
.data_string_13 "@34\0"
.data_string_14 "@17Alloc:@36 %u@17 pg (%U@17 KiB)  Free:@36 %u@17 pg (%U@17 KiB)  Zero-pg:@34 1@r\n\0"
.data_string_15 "@37Legend (main):@r  \0"
.data_string_16 "@r=seg  \0"
.data_string_17 "@r=blk  \0"
.data_string_18 "@r=1blk  \0"
.data_string_19 "@r=sys  \0"
.data_string_20 "@r=free\n\0"
.data_string_21 "@37Legend (ext):@r   \0"
.data_string_22 "@r=ext-alloc  \0"
.data_string_23 "@r=zero-pg  \0"
.data_string_24 "@37     Wire Wrap Odyssey -- Memory Status@r\n\0"
.var_s_range_start "\0\0"
.var_s_total_bytes "\0\0"
.var_s_ledger_count "\0\0"
.var_s_sysody_addr "\0\0"
.var_s_sysody_ls "\0\0"
.var_s_sysody_le "\0\0"
.var_s_sysody_bytes "\0\0"
.var_s_free_bytes "\0\0"
.var_s_used_bytes "\0\0"
.var_s_alloc_count "\0\0"
.var_s_max_free "\0\0"
.var_s_cur_free "\0\0"
.var_s_i "\0\0"
.var_s_alloc_total "\0\0"
.var_s_alloc_pos "\0\0"
.var_s_alloc_remaining "\0\0"
.var_s_segs16 "\0\0"
.var_s_b16 "\0\0"
.var_s_num_segs "\0"
.var_s_b "\0"
.var_s_in_alloc "\0"
.var_s_is_sysody "\0"
.var_s_is_blk "\0"
.var_s_is_last "\0"
.var_s_cur_color "\0"
.var_s_last_color "\0"
.var_s_ch "\0"
.var_s_dwin "\0\0"
.var_se_ext_ledger "\0\0"
.var_se_page "\0\0"
.var_se_cnt16 "\0\0"
.var_se_byte_idx "\0"
.var_se_bit_mask "\0"
.var_se_allocated "\0"
.var_se_alloc_count "\0"
.var_se_ext_free "\0"
.var_se_cur_color "\0"
.var_se_last_color "\0"
.var_se_ch "\0"
.var_se_alloc_kib "\0\0"
.var_se_free_kib "\0\0"
