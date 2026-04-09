// File: rtl/pipelined_adder_32bit.sv
// ------------------------------------------------------------------
// Corrected RTL code for the 32‐bit pipelined adder.
// Fixes:
//   • Mis‐alignment of pipeline stage outputs (the stage1 result was 
//     registered too many times and ended up in the wrong byte position).
//   • The done signal was generated too early; now it is generated 
//     using a 4‐cycle pipeline chain driven by the start signal.
//   • The start signal is now incorporated into the control chain.
// ------------------------------------------------------------------

module pipelined_adder_32bit (
    input         clk,       // Synchronous to posedge of clk 
    input         reset,     // Synchronous active high reset
    input         start,     // Active high signal to indicate valid input data
    input  [31:0] A,        // 32-bit operand for addition  
    input  [31:0] B,        // 32-bit operand for addition  
    output [31:0] S,        // Final sum or result 
    output        Co,       // Final carry out 
    output        done      // Completion signal, active high when computation is complete    
);

   // Divide the 32-bit inputs into 8-bit segments
   wire [7:0] A0, B0, A1, B1, A2, B2, A3, B3;
   assign A0 = A[7:0];
   assign B0 = B[7:0];
   assign A1 = A[15:8];
   assign B1 = B[15:8];
   assign A2 = A[23:16];
   assign B2 = B[23:16];
   assign A3 = A[31:24];
   assign B3 = B[31:24];

   // Pipeline stage outputs and carry signals
   wire [7:0] s0, s1, s2, s3;
   wire       carry0, carry1, carry2, carry3;

   // ----------------------------------------------------------------
   // Stage 1: Compute least-significant byte (LSB)
   // ----------------------------------------------------------------
   carry_lookahead_adder #(8) stage1 (
       .clk    (clk),
       .reset  (reset),
       .A      (A0),
       .B      (B0),
       .Cin    (1'b0),
       .S      (s0),
       .carry  (carry0)
   );
   // Register stage 1 output for S[7:0]
   dff #(8) stage1_reg (
       .clk  (clk),
       .reset(reset),
       .D    (s0),
       .Q    (S[7:0])
   );

   // ----------------------------------------------------------------
   // Stage 2: Compute second byte using carry from stage 1
   // ----------------------------------------------------------------
   carry_lookahead_adder #(8) stage2 (
       .clk    (clk),
       .reset  (reset),
       .A      (A1),
       .B      (B1),
       .Cin    (carry0),
       .S      (s1),
       .carry  (carry1)
   );
   // Register stage 2 output for S[15:8]
   dff #(8) stage2_reg (
       .clk  (clk),
       .reset(reset),
       .D    (s1),
       .Q    (S[15:8])
   );

   // ----------------------------------------------------------------
   // Stage 3: Compute third byte using carry from stage 2
   // ----------------------------------------------------------------
   carry_lookahead_adder #(8) stage3 (
       .clk    (clk),
       .reset  (reset),
       .A      (A2),
       .B      (B2),
       .Cin    (carry1),
       .S      (s2),
       .carry  (carry2)
   );
   // Register stage 3 output for S[23:16]
   dff #(8) stage3_reg (
       .clk  (clk),
       .reset(reset),
       .D    (s2),
       .Q    (S[23:16])
   );