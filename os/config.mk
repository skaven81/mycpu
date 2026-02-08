# config.mk - Single source of truth for build configuration

#------------------------------------------------------------------------------
# Paths - Use Make's path functions instead of shell
#------------------------------------------------------------------------------
# Get the directory of this makefile (the root)
ROOT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
ASSEMBLER_DIR := $(ROOT_DIR)../assembler
C_COMPILER_DIR := $(ROOT_DIR)../c_compiler

BIOS_DIR := $(ROOT_DIR)bios
SYSTEM_DIR := $(ROOT_DIR)system
UTIL_DIR := $(ROOT_DIR)util

# Build artifacts from BIOS
BIOS_SYM := $(BIOS_DIR)/bios.sym
BIOS_HEX := $(BIOS_DIR)/bios.hex
OPCODES_FILE := $(ASSEMBLER_DIR)/opcodes.out

# Installation
INSTALL_DIRECTORY := /media/skaven/ODYSSEY
INSTALL_SUBDIR := SYS

#------------------------------------------------------------------------------
# Tools
#------------------------------------------------------------------------------
ASSEMBLER := $(ASSEMBLER_DIR)/assembler.py
C_COMPILER := $(C_COMPILER_DIR)/c_compiler.py
OPCODES_GEN := $(ASSEMBLER_DIR)/gen_opcodes.sh

# Use wildcard instead of ls - it's Make-native
MACROS := $(wildcard $(ASSEMBLER_DIR)/asm_macros)

#------------------------------------------------------------------------------
# Verbosity Control
#------------------------------------------------------------------------------
C_VERBOSE ?= quiet
ASM_VERBOSE ?= quiet

# Map verbosity levels to compiler flags - using Make's computed variables
C_VERBOSE_FLAG = $(C_VERBOSE_FLAG_$(C_VERBOSE))
C_VERBOSE_FLAG_quiet :=
C_VERBOSE_FLAG_verbose := -v
C_VERBOSE_FLAG_debug := -vv

ASM_VERBOSE_FLAG = $(ASM_VERBOSE_FLAG_$(ASM_VERBOSE))
ASM_VERBOSE_FLAG_quiet :=
ASM_VERBOSE_FLAG_verbose := -v
ASM_VERBOSE_FLAG_debug := -vv

# Logging: Use Make's conditional assignment instead of ifeq blocks
C_LOG_REDIRECT = $(C_LOG_REDIRECT_$(C_VERBOSE))
C_LOG_REDIRECT_quiet :=
C_LOG_REDIRECT_verbose := 2>&1 | tee c_compiler.log
C_LOG_REDIRECT_debug := 2>&1 | tee c_compiler.log

ASM_LOG_REDIRECT = $(ASM_LOG_REDIRECT_$(ASM_VERBOSE))
ASM_LOG_REDIRECT_quiet :=
ASM_LOG_REDIRECT_verbose := 2>&1 | tee assembler.log
ASM_LOG_REDIRECT_debug := 2>&1 | tee assembler.log

#------------------------------------------------------------------------------
# Default Build Flags
#------------------------------------------------------------------------------
# Assembler flags - use addprefix for --macros
ASM_FLAGS := --opcodes $(OPCODES_FILE)
ASM_FLAGS += $(addprefix --macros ,$(MACROS))

# For ODY files (not BIOS)
ODY_ASM_FLAGS := $(ASM_FLAGS) --symbols $(BIOS_SYM) --odyssey

# C compiler flags
C_FLAGS :=
C_INCLUDES := -I$(BIOS_DIR)/lib

#------------------------------------------------------------------------------
# Build Configuration
#------------------------------------------------------------------------------
# Ensure tee pipe doesn't mask failures
SHELL := /bin/bash
.SHELLFLAGS := -o pipefail -c

# Default target for utilities
MEM_TARGET := main

# Max command name length
MAX_CMD_LENGTH := 8

#------------------------------------------------------------------------------
# Silent/Verbose output control - Use Make's @ prefix conditionally
#------------------------------------------------------------------------------
# Use MAKEFLAGS Q (quiet) variable pattern
# Set Q empty for verbose, @ for quiet
ifeq ($(VERBOSE_MAKE),1)
  Q :=
else
  Q := @
endif

#------------------------------------------------------------------------------
# Export all variables to sub-makes
#------------------------------------------------------------------------------
export
