# =============================================================
# Script       : sim_bist_fail.do
# Description  : ModelSim simulation script for BIST FAIL case.
#                Compiles tb2 (fault injection), runs simulation.
# Usage        : vsim -c -do scripts/modelsim/sim_bist_fail.do
# =============================================================

quietly set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ../..]]

vlib work
vmap work work

vlog -work work "$PROJECT_ROOT/tb/tb2_bist_fail.v"

vsim -c work.tb2_bist_fail

log -r /*
run -all

quit -f
