# ==============================================================================
# Verilog Project Makefile
# ==============================================================================
# Expected Directory Structure:
#   src/   - Source Verilog files (*.v)
#   tb/    - Testbench Verilog files (*.v)
#   lib/   - Library Verilog files (*.v)
#   build/ - Output directory for compiled files and waveforms
#
# Available Targets:
#   make help    - Show usage instructions
#   make all     - Setup, compile, and run simulation
#   make compile - Compile the project
#   make test    - Run the simulation
#   make view    - Open waveform in GTKWave
#   make clean   - Clean build artifacts
# ==============================================================================

IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

SRC_DIR = src
TB_DIR = tb
LIB_DIR = lib
BUILD_DIR = build

FLAGS = -g2012 -Wall -I$(SRC_DIR) -y $(LIB_DIR) # -g2012 pour utiliser sv au lieu de v

SOURCES = $(wildcard $(LIB_DIR)/*.sv) $(wildcard $(SRC_DIR)/*.sv) 
TESTBENCHES = $(wildcard $(TB_DIR)/*.sv)
TARGET = $(BUILD_DIR)/sim_out
FST_FILE = $(BUILD_DIR)/simulation.fst

# Set default goal to help so that running just "make" provides instructions
.DEFAULT_GOAL := help

.PHONY: help all compile test view clean setup

help:
	@echo "Missing or invalid target. Please use one of the following:"
	@echo "  make help    : Show this help message"
	@echo "  make all     : Setup, compile, and run the simulation"
	@echo "  make compile : Compile the Verilog sources and testbenches"
	@echo "  make test    : Run the compiled simulation"
	@echo "  make view    : Open the generated VCD waveform in GTKWave"
	@echo "  make clean   : Remove the build directory and generated files"
	@echo "  make asm PROG=mon_programm : compile your program file into hex"

all: clean setup compile test

setup:
	@mkdir -p $(BUILD_DIR)

compile: setup
	$(IVERILOG) $(FLAGS) -o $(TARGET) $(SOURCES)  $(TESTBENCHES) 2>&1 | grep -v "sorry: constant selects" 
#; exit $${PIPESTATUS[0]}

test: compile
	@echo "Simulation en cours..."
	$(VVP) $(TARGET) -fst

view:
	@if [ -f $(FST_FILE) ]; then $(GTKWAVE) $(FST_FILE); else echo "FST introuvable."; fi

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp *.fst *.lxt2

# ==============================================================================
# RISC-V Program Compilation
# ==============================================================================
# Description:
#   Compile a RISC-V assembly file from programms/src into a hex file
#   in programms/bin, ready to be loaded into the instruction memory.
#
# Usage:
#   make asm PROG=<program_name>
#
# Example:
#   make asm PROG=main  (will compile programms/src/main.s)
# ==============================================================================

.PHONY: asm asm-clean

# --- Tools ---
RISCV_AS = riscv64-unknown-elf-as
RISCV_LD = riscv64-unknown-elf-ld
RISCV_OBJCOPY = riscv64-unknown-elf-objcopy
PYTHON = python3

# --- Directories ---
PROG_DIR = programms
PROG_SRC_DIR = $(PROG_DIR)/src
PROG_TEMP_DIR = $(PROG_DIR)/temp
PROG_BIN_DIR = $(PROG_DIR)/bin
PROG_CONVERTER = $(PROG_DIR)/bin_to_hex.py

# --- Default program name ---
PROG ?= main

# --- File paths ---
PROG_SRC_FILE = $(PROG_SRC_DIR)/$(PROG).s
PROG_OBJ_FILE = $(PROG_TEMP_DIR)/$(PROG).o
PROG_ELF_FILE = $(PROG_TEMP_DIR)/$(PROG).elf
PROG_BIN_FILE = $(PROG_TEMP_DIR)/$(PROG).bin
PROG_HEX_FILE = $(PROG_BIN_DIR)/$(PROG).hex

asm: $(PROG_HEX_FILE)

$(PROG_HEX_FILE): $(PROG_BIN_FILE)
	@mkdir -p $(PROG_BIN_DIR)
	@echo "Converting binary to hex..."
	@$(PYTHON) $(PROG_CONVERTER) $(PROG_BIN_FILE) $(PROG_HEX_FILE)
	@echo "Hex file generated at $(PROG_HEX_FILE)"

$(PROG_BIN_FILE): $(PROG_ELF_FILE)
	@echo "Extracting .text section..."
	$(RISCV_OBJCOPY) -O binary --only-section=.text $(PROG_ELF_FILE) $(PROG_BIN_FILE)

$(PROG_ELF_FILE): $(PROG_OBJ_FILE)
	@echo "Linking object file..."
	$(RISCV_LD) -m elf32lriscv -Ttext 0x00000000 $(PROG_OBJ_FILE) -o $(PROG_ELF_FILE)

$(PROG_OBJ_FILE): $(PROG_SRC_FILE)
	@mkdir -p $(PROG_TEMP_DIR)
	@echo "Assembling $(PROG_SRC_FILE)..."
	$(RISCV_AS) -march=rv32i -mabi=ilp32 $(PROG_SRC_FILE) -o $(PROG_OBJ_FILE)

asm-clean:
	@echo "Cleaning programms temporary and binary files..."
	rm -rf $(PROG_TEMP_DIR)
	rm -rf $(PROG_BIN_DIR)
