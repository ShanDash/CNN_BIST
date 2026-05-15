// =============================================================
// Module      : conv_core
// Description : 4x4 CNN Convolution Core with 3x3 kernel.
//               Performs sliding-window 3x3 convolution over a
//               4x4 input image, producing 2x2 = 4 valid outputs.
//               Input pixels and kernel weights: 12-bit signed.
//               Outputs: 24-bit signed (accommodates accumulation).
// Authors     : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date        : 2025
// Revision    : 1.0
// =============================================================

module conv_core #(parameter N=4, K=3)(
    // 4x4 Image inputs (16 pixels, 12-bit signed)
    input  signed [11:0] image0,  input signed [11:0] image1,
    input  signed [11:0] image2,  input signed [11:0] image3,
    input  signed [11:0] image4,  input signed [11:0] image5,
    input  signed [11:0] image6,  input signed [11:0] image7,
    input  signed [11:0] image8,  input signed [11:0] image9,
    input  signed [11:0] image10, input signed [11:0] image11,
    input  signed [11:0] image12, input signed [11:0] image13,
    input  signed [11:0] image14, input signed [11:0] image15,

    // 3x3 Kernel weights (9 values, 12-bit signed)
    input  signed [11:0] k0, input signed [11:0] k1, input signed [11:0] k2,
    input  signed [11:0] k3, input signed [11:0] k4, input signed [11:0] k5,
    input  signed [11:0] k6, input signed [11:0] k7, input signed [11:0] k8,

    // 2x2 Convolution outputs (4 values, 24-bit signed)
    output reg signed [23:0] y0, output reg signed [23:0] y1,
    output reg signed [23:0] y2, output reg signed [23:0] y3
);
    reg signed [11:0] image[0:15];
    reg signed [11:0] kernel[0:8];
    integer i, j, m, n, idx;
    reg signed [23:0] sum;

    always @(*) begin
        // Map flat inputs to arrays
        image[0]=image0;   image[1]=image1;   image[2]=image2;   image[3]=image3;
        image[4]=image4;   image[5]=image5;   image[6]=image6;   image[7]=image7;
        image[8]=image8;   image[9]=image9;   image[10]=image10; image[11]=image11;
        image[12]=image12; image[13]=image13; image[14]=image14; image[15]=image15;

        kernel[0]=k0; kernel[1]=k1; kernel[2]=k2;
        kernel[3]=k3; kernel[4]=k4; kernel[5]=k5;
        kernel[6]=k6; kernel[7]=k7; kernel[8]=k8;

        idx = 0;
        for (i=0; i<N-K+1; i=i+1) begin
            for (j=0; j<N-K+1; j=j+1) begin
                sum = 0;
                for (m=0; m<K; m=m+1)
                    for (n=0; n<K; n=n+1)
                        sum = sum + image[(i+m)*N+(j+n)] * kernel[m*K+n];

                case (idx)
                    0: y0 = sum;
                    1: y1 = sum;
                    2: y2 = sum;
                    3: y3 = sum;
                endcase
                idx = idx + 1;
            end
        end
    end

endmodule
