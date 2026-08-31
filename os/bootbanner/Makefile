# os/bootbanner/Makefile
#
# PRISMBAN.ODY -- the "Wire Wrap" boot banner, assembled to fit inside the
# 448-byte bootstrap-code area of a FAT16 boot sector (sector 0 / LBA 0).
# The BIOS boot hook loads LBA 0, checks bytes 0..2 of the code area for the
# ASCII magic 'ODY', and if present relocates + runs it before continuing
# the boot sequence -- so this is not a normal command, it lives in the
# filesystem's boot sector rather than as a SYS/ file.
#
# TWO PHASES -- installing the banner is rare (only when the banner art
# itself changes; see "SELF-CONTAINED" below):
#
#   Phase 1 -- UNPRIVILEGED (build + check):
#     make            assemble prismban.asm -> PRISMBAN.ODY  (fails if > 448 B)
#     make gen        regenerate prismban.asm from gen.py
#     make check      read LBA 0 of the SD card (unprivileged) and report
#                     whether its boot-code area matches the freshly built
#                     PRISMBAN.ODY: up to date / STALE / not installed
#
#   Phase 2 -- ROOT ONLY (rewrites the raw boot sector; refuses as non-root):
#     sudo make install   splice PRISMBAN.ODY into the FAT16 boot-code area,
#                         leaving the BPB and 0x55AA signature untouched
#     sudo make format    mkfs.fat a fresh unpartitioned FAT16 onto the card
#                         and then install (DESTROYS ALL DATA on the card)
#
#   Phase 2 never assembles anything -- it consumes the PRISMBAN.ODY that
#   Phase 1 produced and refuses if it is missing. (Under sudo on an NFS
#   mount, root is squashed to nobody and cannot write build artefacts
#   here anyway; keeping the build unprivileged sidesteps that entirely.)
#   So the running order is always:  make   (as you)  ->  sudo make install
#
#     make clean
#
# SELF-CONTAINED: prismban.asm makes no CALL/JMP outside its own code and
# references no BIOS symbols (it assembles with no symbol table -- see the
# $(FILENAME) rule below). The installed banner therefore does NOT go stale
# when the BIOS is rebuilt; it only needs rebuilding + reinstalling when the
# art (gen.py) changes. The boot hook's contract: the screen is already
# cleared when the banner is CALLed, the banner only paints the framebuffer
# and RETs, and cursor re-init is the caller's job afterwards.
#
# FAT16 boot sector layout (offsets per the maverick-os.dk FAT16 reference,
# http://www.maverick-os.dk/FileSystemFormats/FAT16_FileSystem.html , cross
# checked against os/bios/lib/fat16_mount.asm, the actual consumer):
#
#   0x000   3   jump instruction (EB xx 90 / E9 xx xx)
#   0x003   8   OEM name
#   0x00B  25   BIOS Parameter Block (bytes/sector .. large total sectors)
#   0x024  18   extended BPB: drive#, 0x29 boot sig, volume ID, volume label
#   0x036   8   filesystem type string "FAT16   "   <- BIOS checks this
#   0x03E 448   >>> bootstrap code area <<<          <- the ODY goes here
#   0x1FE   2   0x55 0xAA boot-sector signature      <- BIOS checks this
#
# Everything below 0x03E and the two signature bytes at 0x1FE are left
# byte-for-byte untouched by `make install`; only the 448-byte window is
# rewritten. There is no mkfs/mtools utility that injects boot code into an
# *existing* FAT16 without reformatting (and mtools is not installed here),
# so the splice itself is a single targeted `dd conv=notrunc` of just that
# window -- never a full-sector raw write. `make format` is the mkfs path,
# for initialising a blank card from scratch.

include ../config.mk

FILENAME := PRISMBAN.ODY
SRC      := prismban.asm

# --- FAT16 boot-code window ------------------------------------------------
BOOTCODE_OFF := 62
BOOTCODE_MAX := 448
FSTYPE_OFF := 54
SIG_OFF := 510
# BOOTCODE_OFF 0x03E, first byte after the extended BPB
# BOOTCODE_MAX 0x1FE - 0x03E, room for boot code before the signature
# FSTYPE_OFF   0x036, the "FAT16" type string the BIOS checks
# SIG_OFF      0x1FE, the 0x55 0xAA boot-sector signature

# --- SD card block device -------------------------------------------------
# The card is assumed UNPARTITIONED: the FAT16 filesystem is written straight
# to the disk, so LBA 0 of the whole device *is* the boot sector. Pass the
# device explicitly (for `install`/`format` the card must be unmounted):
#   make check   SDCARD_DEV=/dev/sdX
#   sudo make install SDCARD_DEV=/dev/sdX
# If left blank it is resolved from the mount of $(INSTALL_DIRECTORY), which
# only works while the card is still mounted (fine for `check`).
SDCARD_DEV ?=
ifeq ($(strip $(SDCARD_DEV)),)
SDCARD_DEV := $(shell findmnt -n -o SOURCE --target $(INSTALL_DIRECTORY) 2>/dev/null)
endif

# "0" when running as root, empty otherwise -- gates the Phase 2 recipes.
IS_ROOT := $(filter 0,$(shell id -u))

#--------------------------------------------------------------------------
# Phase 1 -- unprivileged: build
#--------------------------------------------------------------------------
.PHONY: all
all: $(FILENAME)

$(OPCODES_FILE): $(OPCODES_GEN)
	$(Q)echo "  GEN     $@"
	$(Q)bash -c "$< > $@"

# No --symbols: the banner calls nothing in the BIOS, so it assembles with
# no symbol table and does not depend on os/bios/bios.sym (a BIOS rebuild
# never invalidates it).
$(FILENAME): $(SRC) $(OPCODES_FILE)
	$(Q)echo "  ASM     $@"
	$(Q)$(ASSEMBLER) $(ASM_VERBOSE_FLAG) $(ASM_FLAGS) --odyssey \
		--odyssey-target $(MEM_TARGET) \
		--output $@ \
		$(SRC) $(ASM_LOG_REDIRECT)
	$(Q)sz=$$(stat -c%s $@); \
	  if [ $$sz -gt $(BOOTCODE_MAX) ]; then \
	    echo "  ERROR   $@ is $$sz bytes -- exceeds the $(BOOTCODE_MAX)-byte FAT16 boot-code area"; \
	    rm -f $@; exit 1; \
	  fi; \
	  echo "  SIZE    $@ = $$sz bytes ($$(($(BOOTCODE_MAX) - $$sz)) free of $(BOOTCODE_MAX))"

.PHONY: gen
gen:
	$(Q)echo "  GEN     $(SRC)"
	$(Q)python3 gen.py

#--------------------------------------------------------------------------
# Phase 1 -- unprivileged: is the installed banner up to date?
#--------------------------------------------------------------------------
# Reads the first 512 bytes of SDCARD_DEV with plain `dd` (no sudo) and
# compares the boot-code window against the freshly built PRISMBAN.ODY.
# Exit 0 only when they match byte-for-byte; stale / not installed (1) and
# could-not-check (2) both surface through make as a build failure with a
# message saying which.
.PHONY: check
check: $(FILENAME)
	$(Q)dev='$(SDCARD_DEV)'; off=$(BOOTCODE_OFF); sz=$$(stat -c%s $(FILENAME)); \
	if [ -z "$$dev" ]; then \
	  echo "  CHECK   SD card device unknown -- pass SDCARD_DEV=/dev/sdX (or mount the card)"; exit 2; fi; \
	if [ ! -e "$$dev" ]; then echo "  CHECK   $$dev does not exist"; exit 2; fi; \
	tmp=$$(mktemp) && win=$$(mktemp) || exit 2; trap 'rm -f "$$tmp" "$$win"' EXIT; \
	if ! dd if="$$dev" bs=512 count=1 status=none of="$$tmp" 2>/dev/null; then \
	  echo "  CHECK   cannot read $$dev as $$(id -un) -- this check is unprivileged."; \
	  echo "          Mount the card so your desktop session grants read access, then re-run."; \
	  echo "          (Do not 'sudo make check' on this NFS tree: squashed root cannot rebuild $(FILENAME).)"; \
	  exit 2; fi; \
	sig=$$(dd if="$$tmp" bs=1 skip=$(SIG_OFF) count=2 status=none | od -An -tx1 | tr -d ' \n'); \
	fst=$$(dd if="$$tmp" bs=1 skip=$(FSTYPE_OFF) count=5 status=none); \
	if [ "$$sig" != "55aa" ] || [ "$$fst" != "FAT16" ]; then \
	  echo "  CHECK   $$dev LBA 0 is not a FAT16 boot sector (sig=$$sig type='$$fst')"; exit 2; fi; \
	magic=$$(dd if="$$tmp" bs=1 skip=$$off count=3 status=none); \
	if [ "$$magic" != "ODY" ]; then \
	  echo "  CHECK   no boot banner on $$dev (boot-code area does not begin with 'ODY')"; \
	  echo "          Install:  sudo $(MAKE) install SDCARD_DEV=$$dev"; exit 1; fi; \
	dd if="$$tmp" bs=1 skip=$$off count=$$sz status=none of="$$win" 2>/dev/null; \
	if cmp -s "$$win" $(FILENAME); then \
	  echo "  CHECK   up to date -- $$dev carries the current $(FILENAME) ($$sz bytes)"; \
	else \
	  echo "  CHECK   STALE -- $$dev boot banner differs from the freshly built $(FILENAME)"; \
	  echo "          Update:  sudo $(MAKE) install SDCARD_DEV=$$dev"; exit 1; fi

#--------------------------------------------------------------------------
# Phase 2 -- ROOT ONLY: install / format
#--------------------------------------------------------------------------
ifeq ($(IS_ROOT),)
# Not root: define the privileged targets as clean, non-destructive refusals.
.PHONY: install format
install format:
	$(Q)echo "  ERROR   '$@' rewrites the raw boot sector of the SD card and must run as root."
	$(Q)echo "          Re-run as:  sudo $(MAKE) $@ SDCARD_DEV=/dev/sdX"
	$(Q)exit 1
else

# Splice PRISMBAN.ODY into the boot-code window. Refuses unless LBA 0
# already carries a FAT16 boot sector (0x55AA signature + "FAT16" type
# string), so a wrong or blank device is never scribbled on. Prompts once
# unless FORCE=1.
# NOTE: no $(FILENAME) prerequisite -- Phase 2 must not run the assembler
# (squashed root cannot write here over NFS). It requires the Phase 1
# artefact to exist already and refuses cleanly otherwise.
.PHONY: install
install:
	$(Q)if [ ! -f $(FILENAME) ]; then \
	  echo "  ERROR   $(FILENAME) not built yet -- run Phase 1 first, as your normal user:"; \
	  echo "          make -C $(CURDIR)"; \
	  echo "          then re-run:  sudo $(MAKE) install SDCARD_DEV=$(SDCARD_DEV)"; exit 1; fi
	$(Q)dev='$(SDCARD_DEV)'; off=$(BOOTCODE_OFF); max=$(BOOTCODE_MAX); \
	if [ -z "$$dev" ]; then \
	  echo "  ERROR   no SD card device. Pass SDCARD_DEV=/dev/sdX (card must be unmounted)."; exit 1; fi; \
	if [ ! -b "$$dev" ]; then echo "  ERROR   $$dev is not a block device"; exit 1; fi; \
	if mount | grep -q "^$$dev "; then \
	  echo "  ERROR   $$dev is mounted -- unmount it first: umount $$dev"; exit 1; fi; \
	sz=$$(stat -c%s $(FILENAME)); \
	if [ $$sz -gt $$max ]; then echo "  ERROR   $(FILENAME) is $$sz bytes (> $$max)"; exit 1; fi; \
	magic=$$(dd if=$(FILENAME) bs=1 count=3 status=none); \
	if [ "$$magic" != "ODY" ]; then echo "  ERROR   $(FILENAME) does not start with 'ODY' magic"; exit 1; fi; \
	sig=$$(dd if="$$dev" bs=1 skip=$(SIG_OFF) count=2 status=none | od -An -tx1 | tr -d ' \n'); \
	if [ "$$sig" != "55aa" ]; then \
	  echo "  ERROR   $$dev LBA 0 is not a boot sector (signature $$sig, want 55aa)."; \
	  echo "          Format it first:  $(MAKE) format SDCARD_DEV=$$dev"; exit 1; fi; \
	fst=$$(dd if="$$dev" bs=1 skip=$(FSTYPE_OFF) count=5 status=none); \
	if [ "$$fst" != "FAT16" ]; then \
	  echo "  ERROR   $$dev LBA 0 filesystem type is '$$fst', not FAT16 -- refusing."; exit 1; fi; \
	if [ -z "$(FORCE)" ]; then \
	  printf "  Splice %s (%s B) into the boot-code area of %s at offset %s?\n  BPB (0x00-0x3D) and 0x55AA signature stay untouched. [y/N] " \
	    "$(FILENAME)" "$$sz" "$$dev" "$$off"; \
	  read ans; case "$$ans" in y|Y|yes|YES) ;; *) echo "  aborted"; exit 1;; esac; \
	fi; \
	echo "  INSTALL $(FILENAME) -> $$dev  [byte $$off .. $$((off + sz - 1))]"; \
	dd if=$(FILENAME) of="$$dev" bs=1 seek=$$off conv=notrunc status=none; \
	sync; \
	if dd if="$$dev" bs=1 skip=$$off count=$$sz status=none | cmp -s - $(FILENAME); then \
	  echo "  VERIFY  ok -- $$sz bytes match"; \
	else \
	  echo "  ERROR   readback mismatch"; exit 1; fi

# Fresh unpartitioned FAT16 + banner. DESTROYS ALL DATA on SDCARD_DEV.
# No $(FILENAME) prerequisite (see install, above).
.PHONY: format
format:
	$(Q)if [ ! -f $(FILENAME) ]; then \
	  echo "  ERROR   $(FILENAME) not built yet -- run Phase 1 first, as your normal user:"; \
	  echo "          make -C $(CURDIR)"; \
	  echo "          then re-run:  sudo $(MAKE) format SDCARD_DEV=$(SDCARD_DEV)"; exit 1; fi
	$(Q)dev='$(SDCARD_DEV)'; \
	if [ -z "$$dev" ]; then echo "  ERROR   pass SDCARD_DEV=/dev/sdX"; exit 1; fi; \
	if [ ! -b "$$dev" ]; then echo "  ERROR   $$dev is not a block device"; exit 1; fi; \
	if mount | grep -q "^$$dev "; then echo "  ERROR   $$dev is mounted -- unmount it first"; exit 1; fi; \
	if [ -z "$(FORCE)" ]; then \
	  printf "  mkfs.fat -F 16 on %s -- THIS ERASES THE ENTIRE CARD. [y/N] " "$$dev"; \
	  read ans; case "$$ans" in y|Y|yes|YES) ;; *) echo "  aborted"; exit 1;; esac; \
	fi; \
	echo "  MKFS    $$dev  (FAT16, unpartitioned, 1 reserved sector, label ODYSSEY)"; \
	mkfs.fat -F 16 -R 1 -n ODYSSEY "$$dev"; \
	$(MAKE) install SDCARD_DEV="$$dev" FORCE=1

endif

#--------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------
.PHONY: clean
clean:
	$(Q)echo "  CLEAN   bootbanner"
	$(Q)rm -f $(FILENAME) *.log *.sym *.hex
	$(Q)rm -f prism.ans prism.chr prism.clr chrome.ans chrome.chr chrome.clr \
	         phosphor.ans phosphor.chr phosphor.clr nameplate.ans nameplate.chr \
	         nameplate.clr preview-all.ans banners.h
