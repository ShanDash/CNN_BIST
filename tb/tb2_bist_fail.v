// =============================================================
// Testbench    : tb2_bist_fail
// Description  : BIST mode -- fault injection test.
//                Runs LFSR sequence for 50 cycles, computes
//                signature, then flips 1 bit to emulate a
//                stuck-at fault. Expects BIST FAIL result.
// Usage        : vlog tb2_bist_fail.v
//                vsim -c tb2_bist_fail -do "run -all"
// Authors      : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date         : 2025
// =============================================================

`timescale 1ns/1ps

module tb2_bist_fail();

    reg  [7:0]  lfsr;
    reg  [15:0] signature;
    reg  [15:0] golden_sig;
    integer i;

    initial begin
        lfsr       = 8'hA5;
        signature  = 16'h0000;
        golden_sig = 16'h00E6;   // golden signature from fault-free run

        // Run LFSR for 50 cycles and accumulate signature
        for (i = 0; i < 50; i = i + 1) begin
            lfsr      = {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
            signature = signature ^ {8'h00, lfsr};
        end

        // ---- Inject fault: flip bit 0 ----
        signature = signature ^ 16'h0001;

        $display("# ============================================");
        $display("# BIST MODE: FAULT INJECTION TEST");
        $display("# ============================================");
        $display("# Computed Signature = %h", signature);
        $display("# Golden  Signature  = %h", golden_sig);

        if (signature === golden_sig)
            $display("# RESULT: BIST PASS");
        else
            $display("# RESULT: BIST FAIL  <-- fault detected as expected");

        $finish;
    end

endmodule
