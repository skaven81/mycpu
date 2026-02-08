# vim: syntax=asm-mycpu

# ODY executable loader functions
#
# Given a FAT16 file cluster number, file size, and a filesystem handle
# address, will load the file into memory and executes it, then frees the
# memory.
#
# The detailed internal procedure goes like this:
#  1. 512 byte temporary malloc
#  2. The first sector (up to 512 bytes) of the file is loaded into the temp space
#  3. The file is checked for the 'ODY' header
#  4. The flags byte is read (fourth byte of file - see assembler for details on ODY header)
#  5. Memory is allocated based on the value of the flags byte and the file size
#  6. The temporary malloc is freed
#  7. The file is loaded into memory at $base
#  8. Compute $first_prog_byte = $base + 6 + ($num_rewrites << 1)
#  9. For each rewrite $offset in the ODY header:
#       a. read $val at $base + $offset
#       b. write $val + $first_prog_byte back to $base + $offset
# 10. CALL $first_prog_byte
# 11. free memory at $base
#
# The rewriting is what makes the ODY executable relocatable to different
# memory locations. When assembled, each internal jump or memory lookup is
# referenced against a base address of zero (in ROM). When the program is
# copied into RAM, these addresses now represent an _offset_ from the beginning
# of the program, rather than an absolute address.  So for each of these, we
# take the current value (which we now treat as an offset) and add it to the
# address of the first program byte, resulting in an absolute address that will
# function properly for the program being executed.


# Typical usage:
#  1. Allocate a 512-byte memory region
#  2. Push the filesystem handle addr
#  3. Push the address where to load the binary
#  4. Push the number of sectors to load (1 for first sector)
#  5. Push the directory handle address
#  6. Call :fat16_readfile to load the first sector into memory
#  7. Pop the status byte; check for nonzero status = ATA error

#  8. Push the address of the first loaded sector
#  9. Call :fat16_inspect_ody, which will verify that this is an ODY exe and return the flag byte
# 10. Pop the flag byte
#      * if 0xff, not an ODY executable
#      * else, byte is the ODY flag byte

# 11. Free the temporary 512 bytes of memory
# 12. Based on the flag byte, allocate memory to run the binary

# 13. Push the filesystem handle addr
# 14. Push the address where to load the binary
# 15. Push the number of sectors to load (0 for all)
# 16. Push the directory handle address
# 17. Call :fat16_readfile to load the entire file into memory
# 18. Pop the status byte; check for nonzero status = ATA error

# 18. Push the address where the binary is loaded
# 19. Call :fat16_localize_ody to perform the address rewrites
# 20. Pop the address of the first byte of the program
# 21. Use CALL_D to execute the binary
# 22. :free the binary's memory (or not...)
#
# ODY executables must terminate with a RET (or HLT).
#


########
# :fat16_inspect_ody - inspects the first four bytes of a memory
# location presumed to contain an ODY executable.  Verifies that
# the first three bytes are 'O' 'D' 'Y' and if so, returns the
# fourth byte, which is the flag byte.  If it does not appear
# to be an ODY executable, will return 0xff.
#
# Usage:
#  * Push address word to heap
#  * Call function
#  * Pop result byte
:fat16_inspect_ody
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
PUSH_DH
PUSH_DL

CALL :heap_pop_D                # D is at file[0] 'O'

LDA_D_AL
LDI_BL 'O'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .test_d
JMP .not_ody_executable
.test_d
INCR_D                          # D is at file[1] 'D'
LDA_D_AL
LDI_BL 'D'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .test_y
JMP .not_ody_executable
.test_y
INCR_D                          # D is at file[2] 'Y'
LDA_D_AL
LDI_BL 'Y'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .is_ody_executable
JMP .not_ody_executable

.is_ody_executable
INCR_D                          # D is at file[3] flag byte
LDA_D_AL
CALL :heap_push_AL
JMP .inspect_ody_done

.not_ody_executable
LDI_AL 0xff
CALL :heap_push_AL

.inspect_ody_done
POP_DL
POP_DH
POP_BL
POP_AL
RET


########
# :fat16_localize_ody - given the memory address of a loaded
# ODY executable, will rewrite the target addresses in the program
# to localize it to its place in RAM.
#
# Usage:
#   * Push the address of a loaded ODY executable
#   * call :fat16_localize_ody
#   * Pop the address of the first byte of the program
:fat16_localize_ody
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

VAR global word $odyexe_first_byte_of_binary
VAR global word $odyexe_first_byte_of_program
VAR global word $odyexe_rewrites_remaining

CALL :heap_pop_C            # C = program[0] 'O'
ST_CH $odyexe_first_byte_of_binary
ST_CL $odyexe_first_byte_of_binary+1
INCR_C                      # C = program[1] 'D'
INCR_C                      # C = program[2] 'Y'
INCR_C                      # C = program[3] flag byte
INCR_C                      # C = program[4] num. rewrites (high)
LDA_C_BH
INCR_C                      # C = program[5] num. rewrites (low)
LDA_C_BL                    # B contains number of rewrites remaining
INCR_C                      # C = program[6] first offset (or first byte of program if no offsets)
ALUOP_ADDR %B%+%BH% $odyexe_rewrites_remaining
ALUOP_ADDR %B%+%BL% $odyexe_rewrites_remaining+1

# Add C (addr of first offset) to B*2 (bytes of offsets) to get the
# address of the first byte of the program , $odyexe_first_byte_of_program
ALUOP16O_B %ALU16_B<<1%        # multiply number of offsets by 2 to get bytes
MOV_CH_AH
MOV_CL_AL
ALUOP16O_A %ALU16_A+B%            # A now contains the address of the first byte of the program
ALUOP_ADDR %A%+%AH% $odyexe_first_byte_of_program
ALUOP_ADDR %A%+%AL% $odyexe_first_byte_of_program+1

# Begin looping through the rewrites
LD_BH $odyexe_rewrites_remaining
LD_BL $odyexe_rewrites_remaining+1
.rewrite_loop
ALUOP_FLAGS %B%+%BH%        # Begin loop by checking if B (numer of rewrites)
JNZ .rewrite_loop_continue  # is zero.  If so, exit the loop. C tracks our
ALUOP_FLAGS %B%+%BL%        # position in the rewrites list
JNZ .rewrite_loop_continue
JMP .rewrites_done
.rewrite_loop_continue

# read $offset word from rewrite section
LDA_C_BH
INCR_C
LDA_C_BL                    # B contains $offset - how far past $first
INCR_C                      # we'll find a reference to rewrite

# read $ptr from [$base + $offset]
LD_AH $odyexe_first_byte_of_binary
LD_AL $odyexe_first_byte_of_binary+1
ALUOP16O_B %ALU16_A+B%            # B contains the address we want to rewrite;
                            # A contains the base address in memory
LDA_B_DH
ALUOP16O_B %ALU16_B+1%
LDA_B_DL                    # D contains the zero-based offset from the program.
ALUOP16O_B %ALU16_B-1%

LD_AH $odyexe_first_byte_of_program
LD_AL $odyexe_first_byte_of_program+1
# A: address of first byte of program
# B: addr of program word to replace
# C: addr of current rewrite entry (this is our loop index)
# D: offset we need to add to A, then write to address at B

ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
MOV_DH_BH
MOV_DL_BL
ALUOP16O_A %ALU16_A+B%            # add $first to $ptr
POP_BL
POP_BH

ALUOP_ADDR_B %A%+%AH%       # write the modified offset back
ALUOP16O_B %ALU16_B+1%
ALUOP_ADDR_B %A%+%AL%

# decrement $number_of_rewrites (B)
LD_BH $odyexe_rewrites_remaining
LD_BL $odyexe_rewrites_remaining+1
ALUOP16O_B %ALU16_B-1%
ALUOP_ADDR %B%+%BH% $odyexe_rewrites_remaining
ALUOP_ADDR %B%+%BL% $odyexe_rewrites_remaining+1
JMP .rewrite_loop

.rewrites_done
LD_CH $odyexe_first_byte_of_program
LD_CL $odyexe_first_byte_of_program+1
CALL :heap_push_C
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET
