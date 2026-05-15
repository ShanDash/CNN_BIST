// =============================================================
// Module      : relu
// Description : Rectified Linear Unit (ReLU) activation.
//               Operates element-wise on 4 convolution outputs.
//               Clamps negative 24-bit signed values to zero.
//               Pure combinational logic -- zero latency.
// Authors     : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date        : 2025
// Revision    : 1.0
// =============================================================

module relu(
    input  signed [23:0] x0, input signed [23:0] x1,
    input  signed [23:0] x2, input signed [23:0] x3,
    output reg signed [23:0] r0, output reg signed [23:0] r1,
    output reg signed [23:0] r2, output reg signed [23:0] r3
);
    always @(*) begin
        r0 = (x0 < 0) ? 24'sd0 : x0;
        r1 = (x1 < 0) ? 24'sd0 : x1;
        r2 = (x2 < 0) ? 24'sd0 : x2;
        r3 = (x3 < 0) ? 24'sd0 : x3;
    end

endmodule
