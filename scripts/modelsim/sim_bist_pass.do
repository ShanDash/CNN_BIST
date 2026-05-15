# =============================================================
# Script       : sim_bist_pass.do
# Description  : ModelSim simulation script for BIST PASS case.
#                Compiles tb3 (fault-free golden run), runs sim.
# Usage        : vsim -c -do scripts/modelsim/sim_bist_pass.do
# =============================================================

quietly set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ../..]]

vlib work
vmap work work

vlog -work work "$PROJECT_ROOT/tb/tb3_bist_pass.v"

vsim -c work.tb3_bist_pass

log -r /*
run -all

quit -f
