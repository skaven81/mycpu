include ../config.mk

# rules.mk defines the `all` target, but it's included at the bottom of this
# file (after the sdcard-assets rule below), so without this, `sdcard` would
# be picked as the default goal instead of `all`.
.DEFAULT_GOAL := all

INSTALL_SUBDIR := TETRIS

# Asset files that ride along with the built ODY onto the SD card.
ASSET_FILES := $(wildcard *.BIN) $(wildcard *.ANS)

# Adds a prerequisite to rules.mk's sdcard target (no recipe here, so the
# original install recipe for $(FILENAME) still runs) that also copies
# the tetris asset files into place.
sdcard: sdcard-assets

.PHONY: sdcard-assets
sdcard-assets: $(ASSET_FILES)
	$(Q)test -d $(INSTALL_DIRECTORY) || ( echo "ERROR: $(INSTALL_DIRECTORY) does not exist" && exit 1 )
	$(Q)mkdir -p $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)
	$(Q)$(foreach f,$(ASSET_FILES),echo "  INSTALL $(f) -> $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$(f)"; cp $(f) $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$(f);)

include ../rules.mk
