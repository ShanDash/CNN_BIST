// =============================================================
// Module      : lfsr
// Description : 16-bit Linear Feedback Shift Register (LFSR)
//               Used as Test Pattern Generator (TPG) in BIST mode.
//               Taps at bits [15] and [13] (WIDTH-1, WIDTH-3).
//               Non-zero seed: 16'hACE1
// Authors     : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date        : 2025
// Revision    : 1.0
// =============================================================

module lfsr #(parameter WIDTH = 16)(
    input  clk,
    input  rst,
    output reg [WIDTH-1:0] data_out
);
    wire feedback = data_out[WIDTH-1] ^ data_out[WIDTH-3];

    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 16'hACE1;   // non-zero seed
        else
            data_out <= {data_out[WIDTH-2:0], feedback};
    end

endmodule
