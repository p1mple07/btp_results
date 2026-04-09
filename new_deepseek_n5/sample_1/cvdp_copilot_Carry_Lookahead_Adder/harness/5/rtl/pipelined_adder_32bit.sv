module pipelined_adder_32bit (
    input clk,       // Synchronous to posedge of clk 
    input reset,     // Synchronous active high reset
    input [31:0] A,  // 32 bit operand for addition
    input [31:0] B,  // 32 bit operand for addition
    input start,     // Active high signal to initiate addition
    output [31:0] S,  // Final sum or result 
    output Co,       // Final carry out 
    output done      // Completion signal, active high when computation is complete    
);

    wire [7:0] A1, B1, A2, B2, A3, B3;
    wire carry1, carry2, carry3;
    wire [7:0] s13, s23, s32;
    wire [7:0] S13, S23, S32;

    dff #(1) FF00 (.clk(clk), .reset(reset), .D(A[7:0]), .Q(A1));
    dff #(8) FF11 (.clk(clk), .reset(reset), .D(A[15:8]), .Q(A2));
    dff #(8) FF22 (.clk(clk), .reset(reset), .D(A[23:16]), .Q(A3));
    dff #(8) FF33 (.clk(clk), .reset(reset), .D(A[31:24]), .Q(A4));

    dff #(1) FF01 (.clk(clk), .reset(reset), .D(B[7:0]), .Q(B1));
    dff #(8) FF12 (.clk(clk), .reset(reset), .D(B[15:8]), .Q(B2));
    dff #(8) FF23 (.clk(clk), .reset(reset), .D(B[23:16]), .Q(B3));
    dff #(8) FF34 (.clk(clk), .reset(reset), .D(B[31:24]), .Q(B4));

    carry_lookahead_adder #(8) ADD1 (.clk(clk), .reset(reset), .A(A1), .B(B1), .Cin(1'b0), .S(s1), .carry(carry1));
    carry_lookahead_adder #(8) ADD2 (.clk(clk), .reset(reset), .A(A2), .B(B2), .Cin(carry1), .S(s2), .carry(carry2));
    carry_lookahead_adder #(8) ADD3 (.clk(clk), .reset(reset), .A(A3), .B(B3), .Cin(carry2), .S(s3), .carry(carry3));
    carry_lookahead_adder #(8) ADD4 (.clk(clk), .reset(reset), .A(A4), .B(B4), .Cin(carry3), .S(s4), .carry(Co));

    dff #(1) FF41 (.clk(clk), .reset(reset), .D(s1), .Q(S13));
    dff #(8) FF52 (.clk(clk), .reset(reset), .D(s2), .Q(S23));
    dff #(8) FF63 (.clk(clk), .reset(reset), .D(s3), .Q(S32));
    dff #(8) FF74 (.clk(clk), .reset(reset), .D(s4), .Q(S[31:24]));

    carry1 = carry1;
    carry2 = carry2;
    carry3 = carry3;

    // Final sum assembly
    assign S[7:0] = S13;
    assign S[15:8] = S23;
    assign S[23:16] = S32;
    assign S[31:24] = s4;

    // Final carry assignment
    assign Co = carry3;

    // Start signal control
    if (start) begin
        FF00.D = 1;
        FF11.D = 1;
        FF22.D = 1;
        FF33.D = 1;
        FF01.D = 1;
        FF12.D = 1;
        FF23.D = 1;
        FF34.D = 1;
    end else begin
        FF00.D = 0;
        FF11.D = 0;
        FF22.D = 0;
        FF33.D = 0;
        FF01.D = 0;
        FF12.D = 0;
        FF23.D = 0;
        FF34.D = 0;
    end;