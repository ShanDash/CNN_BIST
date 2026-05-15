# =============================================================
# Script       : synth_impl.tcl
# Description  : Vivado TCL script for reproducible synthesis
#                and implementation of the CNN-BIST design on
#                Xilinx Artix-7 XC7A200T (Vivado 2023.1).
#                Generates utilization, timing, and power reports
#                in reports/
# Usage        : vivado -mode batch -source scripts/vivado/synth_impl.tcl
# =============================================================

set PROJECT_ROOT [file normalize [file join [file dirname [info script]] ../..]]
set RPTDIR       "$PROJECT_ROOT/reports"

# ---- Create project ----
create_project cnn_bist_fpga $PROJECT_ROOT/vivado_project -part xc7a200tsbg484-1 -force

# ---- Add RTL sources ----
add_files -norecurse [list \
    "$PROJECT_ROOT/rtl/lfsr.v"             \
    "$PROJECT_ROOT/rtl/misr.v"             \
    "$PROJECT_ROOT/rtl/conv_core.v"        \
    "$PROJECT_ROOT/rtl/relu.v"             \
    "$PROJECT_ROOT/rtl/unified_cnn_bist.v" \
]

set_property top unified_cnn_bist [current_fileset]
update_compile_order -fileset sources_1

# ---- Constraints ----
add_files -fileset constrs_1 -norecurse "$PROJECT_ROOT/scripts/vivado/constraints.xdc"

# ---- Synthesis ----
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# ---- Implementation ----
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# ---- Reports ----
open_run impl_1
report_utilization  -file "$RPTDIR/utilization_post_impl.rpt"
report_timing_summary -file "$RPTDIR/timing_summary_post_impl.rpt"
report_power        -file "$RPTDIR/power_post_impl.rpt"

puts "=== Synthesis and implementation complete. Reports saved to $RPTDIR ==="
