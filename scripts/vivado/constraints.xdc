# =============================================================
# File         : constraints.xdc
# Description  : Timing and pin constraints for CNN-BIST design
#                Target: Xilinx Artix-7 XC7A200T (sbg484-1)
#                Clock target: 60 MHz (achievable ~58 MHz)
# =============================================================

# ---- Primary clock constraint (60 MHz = 16.667 ns period) ----
create_clock -period 16.667 -name sys_clk -waveform {0.000 8.333} [get_ports clk]

# ---- Input delay constraints ----
# Assumes inputs arrive within 2 ns after clock edge
set_input_delay  -clock sys_clk -max 2.000 [get_ports {rst mode}]
set_input_delay  -clock sys_clk -max 2.000 [get_ports {image* k*}]

# ---- Output delay constraints ----
# Outputs must settle 2 ns before next clock edge
set_output_delay -clock sys_clk -max 2.000 [get_ports {final* bist_pass}]

# ---- False paths on reset (async reset, no timing path needed) ----
set_false_path -from [get_ports rst]

# ---- Bitstream settings ----
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4    [current_design]
set_property CONFIG_MODE                   SPIx4 [current_design]
