// =============================================================
// Testbench    : tb3_bist_pass
// Description  : BIST mode -- fault-free (golden) test.
//                Runs same LFSR sequence for 50 cycles with no
//                fault injection. Computed signature must match
//                golden_sig exactly. Expects BIST PASS result.
// Usage        : vlog tb3_bist_pass.v
//                vsim -c tb3_bist_pass -do "run -all"
// Authors      : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date         : 2025
// =============================================================

`timescale 1ns/1ps

module tb3_bist_pass();

    reg  [7:0]  lfsr;
    reg  [15:0] signature;
    reg  [15:0] golden_sig;
    integer i;

    initial begin
        lfsr       = 8'hA5;
        signature  = 16'h0000;
        golden_sig = 16'h00E6;   // golden signature from fault-free run

        // Run LFSR for 50 cycles and accumulate signature (no fault injected)
        for (i = 0; i < 50; i = i + 1) begin
            lfsr      = {lfsr[6:0], lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
            signature = signature ^ {8'h00, lfsr};
        end

        $display("# ============================================");
        $display("# BIST MODE: FAULT-FREE (GOLDEN) TEST");
        $display("# ============================================");
        $display("# Computed Signature = %h", signature);
        $display("# Golden  Signature  = %h", golden_sig);

        if (signature === golden_sig)
            $display("# RESULT: BIST PASS  <-- signature matched");
        else
            $display("# RESULT: BIST FAIL");

        $finish;
    end

endmodule
