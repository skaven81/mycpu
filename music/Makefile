# Makefile - build .MUS song files for the Odyssey music player
#
#   make            convert every *.abc / *.txt source here into NAME.MUS
#   make test       run the mkmus.py unit tests (creates mkmus/.venv via uv)
#   make sdcard     copy the .MUS files to $(INSTALL_DIRECTORY)/MUSIC
#   make clean      remove generated .MUS files
#
# See README.md for the source formats. Each source's basename becomes the
# uppercased 8.3 name on the SD card, so it must be at most 8 characters.

PYTHON ?= python3
MKMUS := mkmus/mkmus.py
MKMUS_SRC := $(wildcard mkmus/*.py)
MKMUS_FLAGS :=

INSTALL_DIRECTORY ?= /media/skaven/ODYSSEY
INSTALL_SUBDIR := MUSIC

ifeq ($(VERBOSE_MAKE),1)
  Q :=
else
  Q := @
endif

SOURCES := $(sort $(wildcard *.abc *.txt))
upper = $(shell echo '$(1)' | tr a-z A-Z)
mus_name = $(call upper,$(basename $(1))).MUS
SONGS := $(foreach s,$(SOURCES),$(call mus_name,$(s)))

.DELETE_ON_ERROR:
.PHONY: all test sdcard clean

all: $(SONGS)

# Per-song options. ABC files carry their own tempo in Q:; the bespoke
# format has no tempo field, so it's set here.
TETRIS.MUS: MKMUS_FLAGS += --tempo 150

define song_rule
$(call mus_name,$(1)): $(1) $(MKMUS_SRC)
	$$(Q)n='$(basename $(1))'; [ $$$${#n} -le 8 ] || { echo "ERROR: '$(1)': basename longer than 8 characters (not FAT16 8.3)"; exit 1; }
	$$(Q)echo "  MKMUS   $$< -> $$@"
	$$(Q)$$(PYTHON) $$(MKMUS) $$(MKMUS_FLAGS) -o $$@ $$<
endef
$(foreach s,$(SOURCES),$(eval $(call song_rule,$(s))))

mkmus/.venv:
	$(Q)uv venv -q $@
	$(Q)uv pip install -q -p $@ pytest

test: mkmus/.venv
	$(Q)cd mkmus && .venv/bin/pytest -q

sdcard: $(SONGS)
	$(Q)test -d $(INSTALL_DIRECTORY) || ( echo "ERROR: $(INSTALL_DIRECTORY) does not exist" && exit 1 )
	$(Q)mkdir -p $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)
	$(Q)for f in $(SONGS); do echo "  INSTALL $$f -> $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$$f"; cp $$f $(INSTALL_DIRECTORY)/$(INSTALL_SUBDIR)/$$f; done

clean:
	$(Q)echo "  CLEAN   music"
	$(Q)rm -f $(SONGS)
