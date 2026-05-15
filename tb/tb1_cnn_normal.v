// =============================================================
// Testbench    : tb1_cnn_normal
// Description  : Tests CNN inference mode.
//                Applies a deterministic 4x4 image and 3x3 kernel,
//                displays convolution and ReLU outputs to console.
// Usage        : vlog tb1_cnn_normal.v ../rtl/conv_core.v ../rtl/relu.v
//                vsim -c tb1_cnn_normal -do "run -all"
// Authors      : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date         : 2025
// =============================================================

`timescale 1ns/1ps

module tb1_cnn_normal();

    reg  signed [11:0] image  [0:15];
    reg  signed [11:0] kernel [0:8];
    wire signed [23:0] y0, y1, y2, y3;
    wire signed [23:0] r0, r1, r2, r3;

    // Instantiate convolution core
    conv_core uut (
        image[0],  image[1],  image[2],  image[3],
        image[4],  image[5],  image[6],  image[7],
        image[8],  image[9],  image[10], image[11],
        image[12], image[13], image[14], image[15],
        kernel[0], kernel[1], kernel[2],
        kernel[3], kernel[4], kernel[5],
        kernel[6], kernel[7], kernel[8],
        y0, y1, y2, y3
    );

    // Instantiate ReLU
    relu relu_stage (y0, y1, y2, y3, r0, r1, r2, r3);

    initial begin
        // 4x4 input image: pixels 0..15
        image[0]=0;  image[1]=1;  image[2]=2;  image[3]=3;
        image[4]=4;  image[5]=5;  image[6]=6;  image[7]=7;
        image[8]=8;  image[9]=9;  image[10]=10; image[11]=11;
        image[12]=12; image[13]=13; image[14]=14; image[15]=15;

        // 3x3 kernel: horizontal edge detector
        kernel[0]=1; kernel[1]=0; kernel[2]=-1;
        kernel[3]=1; kernel[4]=0; kernel[5]=-1;
        kernel[6]=1; kernel[7]=0; kernel[8]=-1;

        #10;

        $display("# ============================================");
        $display("# CNN MODE: Stage 1 -- Input Image (4x4)");
        $display("# ============================================");
        $display("# %4d %4d %4d %4d", image[0],  image[1],  image[2],  image[3]);
        $display("# %4d %4d %4d %4d", image[4],  image[5],  image[6],  image[7]);
        $display("# %4d %4d %4d %4d", image[8],  image[9],  image[10], image[11]);
        $display("# %4d %4d %4d %4d", image[12], image[13], image[14], image[15]);

        $display("# ============================================");
        $display("# CNN MODE: Stage 2a -- Kernel (3x3)");
        $display("# ============================================");
        $display("# %4d %4d %4d", kernel[0], kernel[1], kernel[2]);
        $display("# %4d %4d %4d", kernel[3], kernel[4], kernel[5]);
        $display("# %4d %4d %4d", kernel[6], kernel[7], kernel[8]);

        $display("# ============================================");
        $display("# CNN MODE: Stage 2b -- Convolution Output (2x2)");
        $display("# ============================================");
        $display("# %6d %6d", y0, y1);
        $display("# %6d %6d", y2, y3);

        $display("# ============================================");
        $display("# CNN MODE: Stage 3 -- ReLU Output (2x2)");
        $display("# ============================================");
        $display("# %6d %6d", r0, r1);
        $display("# %6d %6d", r2, r3);

        $finish;
    end

endmodule
