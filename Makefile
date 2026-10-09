# ============================================================================
# Makefile for AXI4-Lite UVM VIP
# Default Simulator: Siemens EDA QuestaSim / ModelSim
# ============================================================================

# --- Configuration Variables ---
# Change TOP to match the name of your top-level testbench module (e.g., top, tb_top)
TOP      ?= top
# Change TESTNAME to the name of your default UVM test class
TESTNAME ?= axi4_lite_base_test
SEED     ?= random

# --- Directories ---
RTL_DIR  = rtl
TB_DIR   = tb
SEQ_DIR  = sequences
TEST_DIR = tests

# --- Include paths for `include macros ---
INCDIRS  = +incdir+$(TB_DIR) +incdir+$(SEQ_DIR) +incdir+$(TEST_DIR)

# --- Files to compile ---
# Compiles all SystemVerilog files in the directories. 
RTL_FILES = $(wildcard $(RTL_DIR)/*.sv)
TB_FILES  = $(wildcard $(TB_DIR)/*.sv) $(wildcard $(SEQ_DIR)/*.sv) $(wildcard $(TEST_DIR)/*.sv)

# --- Compilation and Simulation Flags ---
# -cover bces enables Branch, Condition, Expression, and Statement coverage
VLOG_FLAGS = -sv -cover bces $(INCDIRS)
VSIM_FLAGS = -c -coverage -sv_seed $(SEED) +UVM_TESTNAME=$(TESTNAME)

# ============================================================================
# Targets
# ============================================================================
.PHONY: all clean compile run

# 'make all' cleans the directory, compiles the code, and runs the simulation
all: clean compile run

compile:
	@echo "======================================"
	@echo "Compiling RTL and Testbench..."
	@echo "======================================"
	vlib work
	vmap work work
	vlog $(VLOG_FLAGS) $(RTL_FILES) $(TB_FILES)

run:
	@echo "======================================"
	@echo "Running Simulation: $(TESTNAME)"
	@echo "======================================"
	vsim $(VSIM_FLAGS) work.$(TOP) -do "coverage save -onexit coverage.ucdb; run -all; exit"
	@echo "======================================"
	@echo "Generating HTML Coverage Report..."
	@echo "======================================"
	vcover report -html coverage.ucdb -htmldir cov_html_report

clean:
	@echo "======================================"
	@echo "Cleaning up simulation files..."
	@echo "======================================"
	rm -rf work transcript modelsim.ini coverage.ucdb cov_html_report vsim.wlf *.log *.jou
