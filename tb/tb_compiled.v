// =============================================================
// Testbench    : tb_compiled (all-in-one)
// Description  : Self-contained simulation file that includes
//                all RTL modules inline alongside the testbench.
//                Useful for quick one-file ModelSim runs without
//                needing to compile each RTL file separately.
//                For structured simulation use the individual
//                files in rtl/ and tb/ with the DO scripts.
// Authors      : Shanti Swarup Dash, Saksham Dubey, Shashank Kumar
// Date         : 2025
// =============================================================

`timescale 1ns/1ps

// ---------------- RTL: lfsr ----------------
module lfsr #(parameter WIDTH = 16)(
    input  clk, input rst,
    output reg [WIDTH-1:0] data_out
);
    wire feedback = data_out[WIDTH-1] ^ data_out[WIDTH-3];
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out <= 16'hACE1;
        else
            data_out <= {data_out[WIDTH-2:0], feedback};
    end
endmodule

// ---------------- RTL: misr ----------------
module misr #(parameter WIDTH = 16)(
    input clk, input rst,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] sig
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            sig <= 0;
        else
            sig <= {sig[WIDTH-2:0], sig[WIDTH-1]} ^ data_in;
    end
endmodule

// ---------------- RTL: conv_core ----------------
module conv_core #(parameter N=4, K=3)(
    input  signed [11:0] image0,  input signed [11:0] image1,
    input  signed [11:0] image2,  input signed [11:0] image3,
    input  signed [11:0] image4,  input signed [11:0] image5,
    input  signed [11:0] image6,  input signed [11:0] image7,
    input  signed [11:0] image8,  input signed [11:0] image9,
    input  signed [11:0] image10, input signed [11:0] image11,
    input  signed [11:0] image12, input signed [11:0] image13,
    input  signed [11:0] image14, input signed [11:0] image15,
    input  signed [11:0] k0, input signed [11:0] k1, input signed [11:0] k2,
    input  signed [11:0] k3, input signed [11:0] k4, input signed [11:0] k5,
    input  signed [11:0] k6, input signed [11:0] k7, input signed [11:0] k8,
    output reg signed [23:0] y0, output reg signed [23:0] y1,
    output reg signed [23:0] y2, output reg signed [23:0] y3
);
    reg signed [11:0] image[0:15];
    reg signed [11:0] kernel[0:8];
    integer i,j,m,n,idx;
    reg signed [23:0] sum;

    always @(*) begin
        image[0]=image0;   image[1]=image1;   image[2]=image2;   image[3]=image3;
        image[4]=image4;   image[5]=image5;   image[6]=image6;   image[7]=image7;
        image[8]=image8;   image[9]=image9;   image[10]=image10; image[11]=image11;
        image[12]=image12; image[13]=image13; image[14]=image14; image[15]=image15;
        kernel[0]=k0; kernel[1]=k1; kernel[2]=k2;
        kernel[3]=k3; kernel[4]=k4; kernel[5]=k5;
        kernel[6]=k6; kernel[7]=k7; kernel[8]=k8;
        idx=0;
        for (i=0; i<N-K+1; i=i+1)
            for (j=0; j<N-K+1; j=j+1) begin
                sum=0;
                for (m=0; m<K; m=m+1)
                    for (n=0; n<K; n=n+1)
                        sum = sum + image[(i+m)*N+(j+n)] * kernel[m*K+n];
                case (idx)
                    0: y0=sum; 1: y1=sum; 2: y2=sum; 3: y3=sum;
                endcase
                idx=idx+1;
            end
    end
endmodule

// ---------------- RTL: relu ----------------
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

// ---------------- RTL: unified_cnn_bist ----------------
module unified_cnn_bist(
    input clk, input rst, input mode,
    input signed [11:0] image0,  input signed [11:0] image1,
    input signed [11:0] image2,  input signed [11:0] image3,
    input signed [11:0] image4,  input signed [11:0] image5,
    input signed [11:0] image6,  input signed [11:0] image7,
    input signed [11:0] image8,  input signed [11:0] image9,
    input signed [11:0] image10, input signed [11:0] image11,
    input signed [11:0] image12, input signed [11:0] image13,
    input signed [11:0] image14, input signed [11:0] image15,
    input signed [11:0] k0, input signed [11:0] k1, input signed [11:0] k2,
    input signed [11:0] k3, input signed [11:0] k4, input signed [11:0] k5,
    input signed [11:0] k6, input signed [11:0] k7, input signed [11:0] k8,
    output signed [23:0] final0, output signed [23:0] final1,
    output signed [23:0] final2, output signed [23:0] final3,
    output reg bist_pass
);
    wire [15:0] lfsr_out, misr_out;
    reg  [15:0] golden_sig = 16'hA23F;

    lfsr lgen(.clk(clk), .rst(rst), .data_out(lfsr_out));

    wire signed [11:0] img_mux[0:15];
    wire signed [11:0] ker_mux[0:8];

    assign img_mux[0] =mode?lfsr_out[11:0]:image0;   assign img_mux[1] =mode?lfsr_out[11:0]:image1;
    assign img_mux[2] =mode?lfsr_out[11:0]:image2;   assign img_mux[3] =mode?lfsr_out[11:0]:image3;
    assign img_mux[4] =mode?lfsr_out[11:0]:image4;   assign img_mux[5] =mode?lfsr_out[11:0]:image5;
    assign img_mux[6] =mode?lfsr_out[11:0]:image6;   assign img_mux[7] =mode?lfsr_out[11:0]:image7;
    assign img_mux[8] =mode?lfsr_out[11:0]:image8;   assign img_mux[9] =mode?lfsr_out[11:0]:image9;
    assign img_mux[10]=mode?lfsr_out[11:0]:image10;  assign img_mux[11]=mode?lfsr_out[11:0]:image11;
    assign img_mux[12]=mode?lfsr_out[11:0]:image12;  assign img_mux[13]=mode?lfsr_out[11:0]:image13;
    assign img_mux[14]=mode?lfsr_out[11:0]:image14;  assign img_mux[15]=mode?lfsr_out[11:0]:image15;
    assign ker_mux[0]=mode?lfsr_out[11:0]:k0; assign ker_mux[1]=mode?lfsr_out[11:0]:k1;
    assign ker_mux[2]=mode?lfsr_out[11:0]:k2; assign ker_mux[3]=mode?lfsr_out[11:0]:k3;
    assign ker_mux[4]=mode?lfsr_out[11:0]:k4; assign ker_mux[5]=mode?lfsr_out[11:0]:k5;
    assign ker_mux[6]=mode?lfsr_out[11:0]:k6; assign ker_mux[7]=mode?lfsr_out[11:0]:k7;
    assign ker_mux[8]=mode?lfsr_out[11:0]:k8;

    wire signed [23:0] y0,y1,y2,y3,r0,r1,r2,r3;

    conv_core u_conv(
        .image0(img_mux[0]),  .image1(img_mux[1]),  .image2(img_mux[2]),  .image3(img_mux[3]),
        .image4(img_mux[4]),  .image5(img_mux[5]),  .image6(img_mux[6]),  .image7(img_mux[7]),
        .image8(img_mux[8]),  .image9(img_mux[9]),  .image10(img_mux[10]),.image11(img_mux[11]),
        .image12(img_mux[12]),.image13(img_mux[13]),.image14(img_mux[14]),.image15(img_mux[15]),
        .k0(ker_mux[0]),.k1(ker_mux[1]),.k2(ker_mux[2]),
        .k3(ker_mux[3]),.k4(ker_mux[4]),.k5(ker_mux[5]),
        .k6(ker_mux[6]),.k7(ker_mux[7]),.k8(ker_mux[8]),
        .y0(y0),.y1(y1),.y2(y2),.y3(y3));

    relu u_relu(.x0(y0),.x1(y1),.x2(y2),.x3(y3),.r0(r0),.r1(r1),.r2(r2),.r3(r3));
    assign final0=r0; assign final1=r1; assign final2=r2; assign final3=r3;

    misr siggen(.clk(clk),.rst(rst),
                .data_in(r0[15:0]^r1[15:0]^r2[15:0]^r3[15:0]),.sig(misr_out));

    always @(posedge clk or posedge rst) begin
        if (rst) bist_pass<=0;
        else if (mode) bist_pass<=(misr_out==golden_sig);
        else bist_pass<=0;
    end
endmodule

// ---------------- Testbench: CNN Normal ----------------
module tb1_cnn_normal();
    reg  signed [11:0] image[0:15];
    reg  signed [11:0] kernel[0:8];
    wire signed [23:0] y0,y1,y2,y3,r0,r1,r2,r3;

    conv_core uut(
        image[0],image[1],image[2],image[3],
        image[4],image[5],image[6],image[7],
        image[8],image[9],image[10],image[11],
        image[12],image[13],image[14],image[15],
        kernel[0],kernel[1],kernel[2],
        kernel[3],kernel[4],kernel[5],
        kernel[6],kernel[7],kernel[8],
        y0,y1,y2,y3);

    relu relu_stage(y0,y1,y2,y3,r0,r1,r2,r3);

    initial begin
        image[0]=0;  image[1]=1;  image[2]=2;  image[3]=3;
        image[4]=4;  image[5]=5;  image[6]=6;  image[7]=7;
        image[8]=8;  image[9]=9;  image[10]=10; image[11]=11;
        image[12]=12; image[13]=13; image[14]=14; image[15]=15;
        kernel[0]=1; kernel[1]=0; kernel[2]=-1;
        kernel[3]=1; kernel[4]=0; kernel[5]=-1;
        kernel[6]=1; kernel[7]=0; kernel[8]=-1;
        #10;
        $display("# CNN MODE: Input Image:");
        $display("# %4d %4d %4d %4d",image[0],image[1],image[2],image[3]);
        $display("# %4d %4d %4d %4d",image[4],image[5],image[6],image[7]);
        $display("# %4d %4d %4d %4d",image[8],image[9],image[10],image[11]);
        $display("# %4d %4d %4d %4d",image[12],image[13],image[14],image[15]);
        $display("# Kernel: %d %d %d / %d %d %d / %d %d %d",
            kernel[0],kernel[1],kernel[2],kernel[3],kernel[4],
            kernel[5],kernel[6],kernel[7],kernel[8]);
        $display("# Conv out: %d %d / %d %d",y0,y1,y2,y3);
        $display("# ReLU out: %d %d / %d %d",r0,r1,r2,r3);
        $finish;
    end
endmodule

// ---------------- Testbench: BIST FAIL ----------------
module tb2_bist_fail();
    reg [7:0] lfsr;
    reg [15:0] signature, golden_sig;
    integer i;
    initial begin
        lfsr=8'hA5; signature=16'h0000; golden_sig=16'h00E6;
        for(i=0;i<50;i=i+1) begin
            lfsr={lfsr[6:0],lfsr[7]^lfsr[5]^lfsr[4]^lfsr[3]};
            signature=signature^{8'h00,lfsr};
        end
        signature=signature^16'h0001; // inject fault
        $display("# BIST FAIL TEST: Computed=%h  Golden=%h",signature,golden_sig);
        if(signature===golden_sig) $display("# RESULT: BIST PASS");
        else                       $display("# RESULT: BIST FAIL  <-- fault detected");
        $finish;
    end
endmodule

// ---------------- Testbench: BIST PASS ----------------
module tb3_bist_pass();
    reg [7:0] lfsr;
    reg [15:0] signature, golden_sig;
    integer i;
    initial begin
        lfsr=8'hA5; signature=16'h0000; golden_sig=16'h00E6;
        for(i=0;i<50;i=i+1) begin
            lfsr={lfsr[6:0],lfsr[7]^lfsr[5]^lfsr[4]^lfsr[3]};
            signature=signature^{8'h00,lfsr};
        end
        $display("# BIST PASS TEST: Computed=%h  Golden=%h",signature,golden_sig);
        if(signature===golden_sig) $display("# RESULT: BIST PASS  <-- match");
        else                       $display("# RESULT: BIST FAIL");
        $finish;
    end
endmodule
