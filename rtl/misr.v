// =============================================================
// Module      : misr
// Description : 16-bit Multiple Input Signature Register (MISR)
//               Used as Output Response Analyzer (ORA) in BIST mode.
//               Compresses CNN ReLU outputs into a compact signature
//               via cyclic shift + XOR with incoming data.
// Authors     : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date        : 2025
// Revision    : 1.0
// =============================================================

module misr #(parameter WIDTH = 16)(
    input                  clk,
    input                  rst,
    input  [WIDTH-1:0]     data_in,
    output reg [WIDTH-1:0] sig
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            sig <= 0;
        else
            sig <= {sig[WIDTH-2:0], sig[WIDTH-1]} ^ data_in;
    end

endmodule
