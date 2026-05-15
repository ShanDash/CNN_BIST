// =============================================================
// Module      : unified_cnn_bist
// Description : Top-level unified CNN + BIST architecture.
//               mode=0 : CNN inference mode -- external image &
//                        kernel applied; final0..3 are ReLU outputs.
//               mode=1 : BIST mode -- LFSR patterns replace image
//                        & kernel; MISR compacts ReLU outputs into
//                        a signature; bist_pass asserted when
//                        signature matches golden_sig.
//
//               Sub-modules instantiated:
//                 lfsr        -- 16-bit pseudo-random TPG
//                 conv_core   -- 4x4 / 3x3 convolution engine
//                 relu        -- ReLU activation
//                 misr        -- 16-bit signature compactor (ORA)
//
// Target      : Xilinx Artix-7 XC7A200T (Vivado 2023.1)
// Authors     : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date        : 2025
// Revision    : 1.0
// =============================================================

module unified_cnn_bist(
    input  clk,
    input  rst,
    input  mode,    // 0 = CNN mode, 1 = BIST mode

    // External image inputs (used in CNN mode)
    input signed [11:0] image0,  input signed [11:0] image1,
    input signed [11:0] image2,  input signed [11:0] image3,
    input signed [11:0] image4,  input signed [11:0] image5,
    input signed [11:0] image6,  input signed [11:0] image7,
    input signed [11:0] image8,  input signed [11:0] image9,
    input signed [11:0] image10, input signed [11:0] image11,
    input signed [11:0] image12, input signed [11:0] image13,
    input signed [11:0] image14, input signed [11:0] image15,

    // External kernel inputs (used in CNN mode)
    input signed [11:0] k0, input signed [11:0] k1, input signed [11:0] k2,
    input signed [11:0] k3, input signed [11:0] k4, input signed [11:0] k5,
    input signed [11:0] k6, input signed [11:0] k7, input signed [11:0] k8,

    // ReLU-activated convolution outputs
    output signed [23:0] final0, output signed [23:0] final1,
    output signed [23:0] final2, output signed [23:0] final3,

    // BIST result (valid only in BIST mode)
    output reg bist_pass
);

    // ----------------------------------------------------------------
    // LFSR (Test Pattern Generator)
    // ----------------------------------------------------------------
    wire [15:0] lfsr_out;
    lfsr lgen (.clk(clk), .rst(rst), .data_out(lfsr_out));

    // ----------------------------------------------------------------
    // Mode multiplexers -- select LFSR or external inputs
    // ----------------------------------------------------------------
    wire signed [11:0] img_mux [0:15];
    wire signed [11:0] ker_mux [0:8];

    assign img_mux[0]  = mode ? lfsr_out[11:0] : image0;
    assign img_mux[1]  = mode ? lfsr_out[11:0] : image1;
    assign img_mux[2]  = mode ? lfsr_out[11:0] : image2;
    assign img_mux[3]  = mode ? lfsr_out[11:0] : image3;
    assign img_mux[4]  = mode ? lfsr_out[11:0] : image4;
    assign img_mux[5]  = mode ? lfsr_out[11:0] : image5;
    assign img_mux[6]  = mode ? lfsr_out[11:0] : image6;
    assign img_mux[7]  = mode ? lfsr_out[11:0] : image7;
    assign img_mux[8]  = mode ? lfsr_out[11:0] : image8;
    assign img_mux[9]  = mode ? lfsr_out[11:0] : image9;
    assign img_mux[10] = mode ? lfsr_out[11:0] : image10;
    assign img_mux[11] = mode ? lfsr_out[11:0] : image11;
    assign img_mux[12] = mode ? lfsr_out[11:0] : image12;
    assign img_mux[13] = mode ? lfsr_out[11:0] : image13;
    assign img_mux[14] = mode ? lfsr_out[11:0] : image14;
    assign img_mux[15] = mode ? lfsr_out[11:0] : image15;

    assign ker_mux[0] = mode ? lfsr_out[11:0] : k0;
    assign ker_mux[1] = mode ? lfsr_out[11:0] : k1;
    assign ker_mux[2] = mode ? lfsr_out[11:0] : k2;
    assign ker_mux[3] = mode ? lfsr_out[11:0] : k3;
    assign ker_mux[4] = mode ? lfsr_out[11:0] : k4;
    assign ker_mux[5] = mode ? lfsr_out[11:0] : k5;
    assign ker_mux[6] = mode ? lfsr_out[11:0] : k6;
    assign ker_mux[7] = mode ? lfsr_out[11:0] : k7;
    assign ker_mux[8] = mode ? lfsr_out[11:0] : k8;

    // ----------------------------------------------------------------
    // CNN Core
    // ----------------------------------------------------------------
    wire signed [23:0] y0, y1, y2, y3;

    conv_core u_conv (
        .image0(img_mux[0]),  .image1(img_mux[1]),
        .image2(img_mux[2]),  .image3(img_mux[3]),
        .image4(img_mux[4]),  .image5(img_mux[5]),
        .image6(img_mux[6]),  .image7(img_mux[7]),
        .image8(img_mux[8]),  .image9(img_mux[9]),
        .image10(img_mux[10]),.image11(img_mux[11]),
        .image12(img_mux[12]),.image13(img_mux[13]),
        .image14(img_mux[14]),.image15(img_mux[15]),
        .k0(ker_mux[0]), .k1(ker_mux[1]), .k2(ker_mux[2]),
        .k3(ker_mux[3]), .k4(ker_mux[4]), .k5(ker_mux[5]),
        .k6(ker_mux[6]), .k7(ker_mux[7]), .k8(ker_mux[8]),
        .y0(y0), .y1(y1), .y2(y2), .y3(y3)
    );

    // ----------------------------------------------------------------
    // ReLU Activation
    // ----------------------------------------------------------------
    wire signed [23:0] r0, r1, r2, r3;

    relu u_relu (
        .x0(y0), .x1(y1), .x2(y2), .x3(y3),
        .r0(r0), .r1(r1), .r2(r2), .r3(r3)
    );

    assign final0 = r0;
    assign final1 = r1;
    assign final2 = r2;
    assign final3 = r3;

    // ----------------------------------------------------------------
    // MISR (Output Response Analyzer)
    // ----------------------------------------------------------------
    wire [15:0] misr_out;

    misr siggen (
        .clk(clk),
        .rst(rst),
        .data_in(r0[15:0] ^ r1[15:0] ^ r2[15:0] ^ r3[15:0]),
        .sig(misr_out)
    );

    // ----------------------------------------------------------------
    // Golden signature & BIST PASS/FAIL comparison
    // ----------------------------------------------------------------
    reg [15:0] golden_sig = 16'hA23F;

    always @(posedge clk or posedge rst) begin
        if (rst)
            bist_pass <= 1'b0;
        else if (mode)
            bist_pass <= (misr_out == golden_sig);
        else
            bist_pass <= 1'b0;
    end

endmodule
