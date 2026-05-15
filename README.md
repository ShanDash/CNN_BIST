# CNN Core with Integrated BIST Architecture on FPGA

**Design and Implementation of a CNN Core with Integrated Built-In Self-Test (BIST) Architecture on FPGA using Verilog HDL**

> Published in *International Journal of Electrical and Electronics Research (IJEER)*  
> ISSN 2348-6988 (online) | Volume 14, Issue 1, 2026 | Manuscript ID: ER032026012  
> Authors: Shanti Swarup Dash, Saksham Dubey, Shashank Kumar  
> Supervisor: Prof. Rajesh Rohilla  
> Department of Electronics and Communication Engineering  
> Delhi Technological University

---

## Overview

This project implements a unified hardware architecture combining a lightweight **4×4 CNN convolution core** with an integrated **Built-In Self-Test (BIST)** engine in Verilog HDL, synthesized on a **Xilinx Artix-7 (XC7A200T)** FPGA.

The design supports two modes:
- **CNN mode (`mode=0`)** — standard 3×3 convolution + ReLU inference
- **BIST mode (`mode=1`)** — LFSR-generated patterns replace image/kernel inputs; MISR compacts outputs into a signature compared against a golden reference

---

## Repository Structure

```
cnn_bist_fpga/
├── rtl/                        # Synthesizable Verilog RTL
│   ├── lfsr.v                  # 16-bit LFSR (Test Pattern Generator)
│   ├── misr.v                  # 16-bit MISR (Output Response Analyzer)
│   ├── conv_core.v             # 4×4 / 3×3 CNN Convolution Core
│   ├── relu.v                  # ReLU Activation Module
│   └── unified_cnn_bist.v      # Top-level unified CNN+BIST module
│
├── tb/                         # Testbenches
│   ├── tb1_cnn_normal.v        # CNN normal inference test
│   ├── tb2_bist_fail.v         # BIST fault injection (expects FAIL)
│   ├── tb3_bist_pass.v         # BIST golden run (expects PASS)
│   └── tb_compiled.v           # All-in-one single-file simulation
│
├── scripts/
│   ├── modelsim/               # ModelSim DO simulation scripts
│   │   ├── sim_cnn_normal.do   # Run CNN normal testbench
│   │   ├── sim_bist_fail.do    # Run BIST FAIL testbench
│   │   ├── sim_bist_pass.do    # Run BIST PASS testbench
│   │   └── run_regression.do   # Run full regression (all 3 TBs)
│   └── vivado/                 # Vivado TCL synthesis scripts
│       ├── synth_impl.tcl      # Full synthesis + implementation
│       └── constraints.xdc     # Timing and I/O constraints
│
├── reports/
│   └── regression/             # Simulation logs saved here
│
├── docs/                       # Project documentation
│
├── .gitignore
└── README.md
```

---

## Quick Start

### 1. Simulate (ModelSim)

**CNN normal mode:**
```bash
vsim -c -do scripts/modelsim/sim_cnn_normal.do
```

**BIST FAIL (fault injection):**
```bash
vsim -c -do scripts/modelsim/sim_bist_fail.do
```

**BIST PASS (golden run):**
```bash
vsim -c -do scripts/modelsim/sim_bist_pass.do
```

**Full regression (all testbenches):**
```bash
vsim -c -do scripts/modelsim/run_regression.do
```

Logs are saved to `reports/regression/`.

**Quick single-file simulation (all-in-one):**
```bash
vlog tb/tb_compiled.v
vsim -c work.tb1_cnn_normal -do "run -all; quit"
vsim -c work.tb2_bist_fail  -do "run -all; quit"
vsim -c work.tb3_bist_pass  -do "run -all; quit"
```

### 2. Synthesize (Vivado)

```bash
vivado -mode batch -source scripts/vivado/synth_impl.tcl
```

Reports are generated in `reports/`:
- `utilization_post_impl.rpt`
- `timing_summary_post_impl.rpt`
- `power_post_impl.rpt`

---

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │          unified_cnn_bist                │
                    │                                          │
  image[0:15] ──►  │  ┌──────┐   ┌───────────┐  ┌────────┐  │  ──► final[0:3]
  k[0:8]      ──►  │  │ MUX  │──►│ conv_core │─►│  relu  │  │
                    │  └──────┘   └───────────┘  └────┬───┘  │
  lfsr_out    ──►  │                                  │       │
                    │  ┌──────┐                   ┌────▼───┐  │  ──► bist_pass
                    │  │ lfsr │                   │  misr  │  │
                    │  └──────┘                   └────────┘  │
                    │                                          │
                    │  mode=0: CNN inference                   │
                    │  mode=1: BIST self-test                  │
                    └─────────────────────────────────────────┘
```

---

## Results Summary

| Metric              | Value                          |
|---------------------|--------------------------------|
| Target Device       | Xilinx Artix-7 XC7A200T        |
| Tool                | Vivado 2023.1                  |
| Total LUTs          | 398                            |
| Total Registers     | 41                             |
| DSP Slices          | 36                             |
| BRAMs               | 0                              |
| Clock Target        | 60 MHz                         |
| Achieved Fmax       | ~58 MHz                        |
| Estimated Power     | ~0.253 W                       |
| MISR Width          | 16-bit                         |
| Aliasing Probability| ~1.5 × 10⁻⁵                   |

---

## Regression Testing

Tested across 8 LFSR seeds × 2 capture lengths (50 and 100 cycles). All configurations:
- Correctly reported **BIST PASS** when no fault was injected
- Correctly reported **BIST FAIL** when a single bit was flipped

No aliasing observed in any tested case.

---

## Publication

S. S. Dash, S. Kumar and S. Dubey,  
*"Design and Implementation of a CNN Core with Integrated Built-In Self-Test (BIST) Architecture on FPGA using Verilog HDL,"*  
**International Journal of Electrical and Electronics Research (IJEER)**,  
ISSN 2348-6988 (online), Vol. 14, No. 1, 2026.  
Manuscript ID: ER032026012 | Published: 20 March 2026  
Publisher: Research Publish Journals, Lucknow, India — www.researchpublish.com

---


This project is submitted as an academic Major Project at Delhi Technological University. All rights reserved by the authors.
