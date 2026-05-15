# =============================================================
# Script       : run_regression.do
# Description  : Full regression -- runs all 3 testbenches in
#                sequence, prints PASS/FAIL summary to console.
#                Log files saved to reports/regression/
# Usage        : vsim -c -do scripts/modelsim/run_regression.do
# =============================================================

quietly set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ../..]]
quietly set RPTDIR       "$PROJECT_ROOT/reports/regression"

# ---- Compile RTL once ----
vlib work
vmap work work

vlog -work work "$PROJECT_ROOT/rtl/lfsr.v"
vlog -work work "$PROJECT_ROOT/rtl/misr.v"
vlog -work work "$PROJECT_ROOT/rtl/conv_core.v"
vlog -work work "$PROJECT_ROOT/rtl/relu.v"
vlog -work work "$PROJECT_ROOT/rtl/unified_cnn_bist.v"

# ---- Compile all testbenches ----
vlog -work work "$PROJECT_ROOT/tb/tb1_cnn_normal.v"
vlog -work work "$PROJECT_ROOT/tb/tb2_bist_fail.v"
vlog -work work "$PROJECT_ROOT/tb/tb3_bist_pass.v"

echo "============================================"
echo " REGRESSION: tb1_cnn_normal"
echo "============================================"
vsim -c work.tb1_cnn_normal -logfile "$RPTDIR/tb1_cnn_normal.log"
run -all

echo "============================================"
echo " REGRESSION: tb2_bist_fail"
echo "============================================"
vsim -c work.tb2_bist_fail -logfile "$RPTDIR/tb2_bist_fail.log"
run -all

echo "============================================"
echo " REGRESSION: tb3_bist_pass"
echo "============================================"
vsim -c work.tb3_bist_pass -logfile "$RPTDIR/tb3_bist_pass.log"
run -all

echo "============================================"
echo " REGRESSION COMPLETE -- check reports/regression/"
echo "============================================"

quit -f
