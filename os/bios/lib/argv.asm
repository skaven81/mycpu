# vim: syntax=asm-mycpu

###
# :argv_init -- get program arguments from heap (as pushed by BIOS exec loop)
#
# The BIOS exec loop pushes argv then argc to the heap before CALL_D:
#   heap_push_A  (argv base pointer, word)
#   heap_push_A  (argc, 16-bit zero-extended: AH=0x00, AL=count)
#
# After CALL_D, the executed program pops these to get its arguments.
# Call :argv_init at program entry before any other heap operations.
#
# Output:
#   AL = argc (number of argv entries; argv[0] = program name, argv[1..] = args)
#   C  = base address of the argv pointer array
#   AH = 0x00 (high byte of the popped argc word)
#
# The argv array format is (hi_ptr, lo_ptr) pairs, null-terminated (0x0000).
# Each pointer points to a malloc'd null-terminated string owned by the
# BIOS exec loop; the program MUST NOT free them.
#
# Does NOT save/restore AH, AL, or C -- these are output registers.
# If your program needs AH or C after :argv_init, save them before calling.
#
# Example usage:
#   CALL :argv_init      # AL=argc, C=argv base
#   ALUOP_BH %A%+%AL%   # save argc in BH
#   PUSH_CH              # save argv base in C-pair on stack
#   PUSH_CL
###
:argv_init
CALL :heap_pop_A        # A = argc (AH=0x00, AL=count)
CALL :heap_pop_C        # C = argv base address
RET
