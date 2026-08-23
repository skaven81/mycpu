# vim: syntax=asm-mycpu

# NOTE: the boot ATA banner used to print the full "ATA0: <model>
# <firmware> <capacity>MiB" line via :ata_identify_string. That function
# was evicted to os/lib/ata_identify_string.asm to reclaim ROM space, and
# this boot path now uses the slim BIOS-resident :ata_boot_identify
# instead, which prints only "ATA0: present" / "ATA0: not detected" --
# a deliberate behavior change to the boot banner, not a bug.
:boot_ata_init
LDI_BL 0                                # primary master
CALL :heap_push_BL
CALL :ata_boot_identify                 # prints its own banner line

LDI_BL 1                                # primary slave
CALL :heap_push_BL
CALL :ata_boot_identify                 # prints its own banner line
RET
