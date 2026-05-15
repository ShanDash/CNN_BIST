# =============================================================
# Script       : sim_cnn_normal.do
# Description  : ModelSim simulation script for CNN normal mode.
#                Compiles all RTL + tb1, runs simulation, saves
#                waveforms to reports/regression/
# Usage        : vsim -c -do scripts/modelsim/sim_cnn_normal.do
# =============================================================

quietly set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ../..]]

# Create and map work library
vlib work
vmap work work

# Compile RTL
vlog -work work "$PROJECT_ROOT/rtl/lfsr.v"
vlog -work work "$PROJECT_ROOT/rtl/misr.v"
vlog -work work "$PROJECT_ROOT/rtl/conv_core.v"
vlog -work work "$PROJECT_ROOT/rtl/relu.v"
vlog -work work "$PROJECT_ROOT/rtl/unified_cnn_bist.v"

# Compile testbench
vlog -work work "$PROJECT_ROOT/tb/tb1_cnn_normal.v"

# Simulate
vsim -c work.tb1_cnn_normal

# Save waveforms
log -r /*
run -all

quit -f
