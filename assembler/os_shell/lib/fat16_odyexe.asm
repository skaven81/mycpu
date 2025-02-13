# vim: syntax=asm-mycpu

# ODY executable loader function
#
# Given a FAT16 file cluster number, file size, and a filesystem handle
# address, will load the file into memory and executes it, then frees the
# memory.
#
# The detailed procedure goes like this:
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
#  1. Push the memory address of a directory entry
#  2. Push the address word of the FAT16 filesystem handle
#  3. Call :load_and_run_ody, which will:
#      * pop the filesystem handle addr
#      * pop the cluster number of the file
#      * pop the low word of the file size
#      * pop the high word of the file size (can be discarded, as executables > 20k are not possible)
#      * read the first sector -> get memory allocation preference -> allocate memory
#      * allocate memory and load file
#      * perform address rewrites
#      * CALL the first byte of the executable
#      * clean up allocated memory and return
#
# Upon returning from :load_and_run_ody, any memory allocated will have been freed.
# ODY executables must terminate with a RET (or HLT).
#
VAR global word $ody_fs_handle
VAR global word $ody_cluster
VAR global word $ody_filesize
VAR global word $ody_dir_handle
VAR global word $ody_temp_memory
VAR global 3 $ody_memory_base # third byte is size, only used by :malloc method
:fat16_load_and_run_ody
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BH%
ALUOP_PUSH %B%+%BL%
PUSH_CH
PUSH_CL
PUSH_DH
PUSH_DL

# Pop filesystem handle into $ody_fs_handle
CALL :heap_pop_C
ST_CH $ody_fs_handle
ST_CL $ody_fs_handle+1

# Pop directory entry address into A
CALL :heap_pop_A
ALUOP_ADDR %A%+%AH% $ody_dir_handle
ALUOP_ADDR %A%+%AL% $ody_dir_handle+1

# Get the cluster number of the file we'll be loading
CALL :heap_push_A
CALL :fat16_dirent_cluster
CALL :heap_pop_C
ST_CH $ody_cluster
ST_CL $ody_cluster+1

# Get the file size of the file we'll be loading (just the low word)
CALL :heap_push_A
CALL :fat16_dirent_filesize
CALL :heap_pop_C                # low word
ST_CH $ody_filesize
ST_CL $ody_filesize+1
# Pop file size high byte (discard; ODY executables can't be more than 20KiB)
CALL :heap_pop_word

#######
# Read first sector of file into temporary memory
#######

LD_CH $ody_fs_handle
LD_CL $ody_fs_handle+1
CALL :heap_push_C               # filesystem handle addr

LDI_AL 31                       # 32 blocks = 512 bytes
CALL :malloc                    # address in A
CALL :heap_push_A               # target address
ALUOP_ADDR %A%+%AH% $ody_temp_memory
ALUOP_ADDR %A%+%AL% $ody_temp_memory+1

LDI_CL 1
CALL :heap_push_CL              # sectors to load

LD_CH $ody_dir_handle
LD_CL $ody_dir_handle+1
CALL :heap_push_C               # directory entry handle

CALL :fat16_readfile            # status byte on heap
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%
JZ .examine_header              # continue if no errors

LDI_C .ata_err_str              # otherwise, print error message, free memory, and abort
CALL :heap_push_AL
CALL :printf
CALL .free_temp_memory
JMP .load_and_run_done

#######
# Examine header for ODY
#######
.examine_header
LD_DH $ody_temp_memory          # Use D to track our location in the header
LD_DL $ody_temp_memory+1        # D is at file[0] 'O'

LDA_D_AL
LDI_BL 'O'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .test_d
LDI_C .ody_header_str
CALL :print
CALL .free_temp_memory
JMP .load_and_run_done
.test_d
INCR_D                          # D is at file[1] 'D'
LDA_D_AL
LDI_BL 'D'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .test_y
LDI_C .ody_header_str
CALL :print
CALL .free_temp_memory
JMP .load_and_run_done
.test_y
INCR_D                          # D is at file[2] 'Y'
LDA_D_AL
LDI_BL 'Y'
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .read_flag_byte
LDI_C .ody_header_str
CALL :print
CALL .free_temp_memory
JMP .load_and_run_done

#######
# read flag byte and allocate memory
#######
.read_flag_byte
INCR_D                          # D is at file[3] flag byte
LDA_D_AL                        # Flag byte loaded into AL

LDI_BL 0x03                     # lowest two bits are the memory allocation flag
ALUOP_AL %A&B%+%AL%+%BL%        # remove all the other bits
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_de
LDI_BL 0x02
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_e
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .extmalloc_d
LDI_BL 0x01
ALUOP_FLAGS %A&B%+%AL%+%BL%
JEQ .malloc_main

.extmalloc_de
# We don't care about the file size, just allocate two extended
# memory pages, assign them to D and E, and return 0xd000
# TODO: test for filesize >8K and abort
CALL :extmalloc
CALL :heap_pop_CH
ST_CH %d_page%
CALL :extmalloc
CALL :heap_pop_CL
ST_CL %e_page%
LDI_C 0xd000
ST_CH $ody_memory_base
ST_CL $ody_memory_base+1
CALL .free_temp_memory
CALL .do_execute
LD_CH $ody_memory_base
LD_CL $ody_memory_base+1
CALL :heap_push_CL
CALL :extfree
CALL :heap_push_CH
CALL :extfree
JMP .load_and_run_done

.extmalloc_e
# We don't care about the file size, just allocate one extended
# memory page, assign to E, and return 0xe000
# TODO: test for filesize >8K and abort
CALL :extmalloc
CALL :heap_pop_CL
ST_CL %e_page%
LDI_C 0xe000
ST_CH $ody_memory_base
ST_CL $ody_memory_base+1
CALL .free_temp_memory
CALL .do_execute
LD_CH $ody_memory_base
LD_CL $ody_memory_base+1
CALL :heap_push_CL
CALL :extfree
JMP .load_and_run_done

.extmalloc_d
# We don't care about the file size, just allocate one extended
# memory page, assign to D, and return 0xd000
# TODO: test for filesize >16K and abort
CALL :extmalloc
CALL :heap_pop_CL
ST_CL %d_page%
LDI_C 0xd000
ST_CH $ody_memory_base
ST_CL $ody_memory_base+1
CALL .free_temp_memory
CALL .do_execute
LD_CH $ody_memory_base
LD_CL $ody_memory_base+1
CALL :heap_push_CL
CALL :extfree
JMP .load_and_run_done

.malloc_main
# Round the file size up to the nearest 512 bytes
LD_AH $ody_filesize
LD_AL $ody_filesize+1
ALUOP_AH %A>>1%+%AH%
ALUOP_AH %A+1%+%AH%
ALUOP_AH %A<<1%+%AH%
ALUOP_AL %zero%
# Shift right four positions to get the number of
# blocks we need to malloc
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
CALL :shift16_a_right
ALUOP_BL %A%+%AL%   # save size of malloc for when we return
CALL :malloc
ALUOP_ADDR %A%+%AH% $ody_memory_base
ALUOP_ADDR %A%+%AL% $ody_memory_base+1
ALUOP_ADDR %B%+%BL% $ody_memory_base+2
CALL .free_temp_memory
CALL .do_execute
LD_AH $ody_memory_base
LD_AL $ody_memory_base+1
LD_BL $ody_memory_base+2
CALL :free
JMP .load_and_run_done

.load_and_run_done
POP_DL
POP_DH
POP_CL
POP_CH
POP_BL
POP_BH
POP_AL
POP_AH
RET

.free_temp_memory
ALUOP_PUSH %A%+%AH%
ALUOP_PUSH %A%+%AL%
ALUOP_PUSH %B%+%BL%
LD_AH $ody_temp_memory
LD_AL $ody_temp_memory+1
LDI_BL 31
CALL :free
POP_BL
POP_AL
POP_AH
RET

#######
# Performs the actual execution.
# Note that we don't do register preservation because when we return from this
# function everything the parent does is supported by variables, not by register
# values.  So this saves 8 bytes on the stack for other programs to use.
#######
.do_execute
#######
# Read file into memory
LD_DH $ody_fs_handle
LD_DL $ody_fs_handle+1
CALL :heap_push_D           # filesystem handle address

LD_CH $ody_memory_base
LD_CL $ody_memory_base+1
CALL :heap_push_C           # target address

LDI_DL 0x00                 # read whole file
CALL :heap_push_DL

LD_DH $ody_dir_handle
LD_DL $ody_dir_handle+1
CALL :heap_push_D           # directory handle

CALL :fat16_readfile
CALL :heap_pop_AL
ALUOP_FLAGS %A%+%AL%        # Check for ATA error
JZ .address_rewrites
CALL :heap_push_AL
LDI_C .ata_err_str
CALL :printf
JMP .do_execute_done

#######
# Perfom address rewrites
VAR global word $odyexe_first_byte_of_program
VAR global word $odyexe_rewrites_remaining
.address_rewrites
LD_CH $ody_memory_base
LD_CL $ody_memory_base+1    # C = program[0] 'O'
INCR_C                      # C = program[1] 'D'
INCR_C                      # C = program[2] 'Y'
INCR_C                      # C = program[3] flag byte
INCR_C                      # C = program[4] num. rewrites (high)
LDA_C_BH
INCR_C                      # C = program[5] num. rewrites (low)
LDA_C_BL                    # B contains number of rewrites
INCR_C                      # C = program[6] first offset (or first byte of program if no offsets)

ALUOP_ADDR %B%+%BH% $odyexe_rewrites_remaining
ALUOP_ADDR %B%+%BL% $odyexe_rewrites_remaining+1

# Add C (addr of first offset) to B*2 (bytes of offsets) to get the
# address of the first byte of the program , $odyexe_first_byte_of_program
CALL :shift16_b_left        # multiply number of offsets by 2 to get bytes
MOV_CH_AH
MOV_CL_AL
CALL :add16_to_a            # A now contains the address of the first byte of the program
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
JMP .execute_program
.rewrite_loop_continue

# read $offset word from rewrite section
LDA_C_BH
INCR_C
LDA_C_BL                    # B contains $offset - how far past $first
INCR_C                      # we'll find a reference to rewrite

# read $ptr from [$base + $offset]
LD_AH $ody_memory_base
LD_AL $ody_memory_base+1
CALL :add16_to_b            # B contains the address we want to rewrite;
                            # A contains the base address in memory
LDA_B_DH
CALL :incr16_b
LDA_B_DL                    # D contains the zero-based offset from the program.
CALL :decr16_b

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
CALL :add16_to_a            # add $first to $ptr
POP_BL
POP_BH

ALUOP_ADDR_B %A%+%AH%       # write the modified offset back
CALL :incr16_b
ALUOP_ADDR_B %A%+%AL%

# decrement $number_of_rewrites (B)
LD_BH $odyexe_rewrites_remaining
LD_BL $odyexe_rewrites_remaining+1
CALL :decr16_b
JMP .rewrite_loop

#######
# Execute the program
.execute_program
# load $first into D
LD_DH $odyexe_first_byte_of_program
LD_DL $odyexe_first_byte_of_program+1
# Execute
CALL_D
.do_execute_done
RET

.ata_err_str "ATA error reading file: 0x%x\n\0"
.ody_header_str "File does not look like an ODY executable\n\0"
