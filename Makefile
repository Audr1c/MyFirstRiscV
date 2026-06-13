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
VCD_FILE = $(BUILD_DIR)/simulation.vcd

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

all: setup compile test

setup:
	@mkdir -p $(BUILD_DIR)

compile: setup
	$(IVERILOG) $(FLAGS) -o $(TARGET) $(SOURCES)  $(TESTBENCHES) 2>&1 | grep -v "sorry: constant selects" 
#; exit $${PIPESTATUS[0]}

test: compile
	@echo "Simulation en cours..."
	$(VVP) $(TARGET)

view:
	@if [ -f $(VCD_FILE) ]; then $(GTKWAVE) $(VCD_FILE); else echo "VCD introuvable."; fi

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp
