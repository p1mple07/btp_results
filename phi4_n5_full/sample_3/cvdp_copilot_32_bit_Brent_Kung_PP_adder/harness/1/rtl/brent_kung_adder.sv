module brent_kung_adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic carry_in,
    output logic [31:0] sum,
    output logic carry_out
);

    // Bit‐level propagate and generate signals
    logic [31:0] P1, G1;
    // Intermediate signals for the carry tree
    logic [15:0] G2, P2;
    logic [7:0]  G3, P3;
    logic [3:0]  G4, P4;
    logic [1:0]  G5, P5;
    logic        G6, P6;
    // Carry signals: C[1] is the carry for bit0, C[32] is the final carry_out.
    logic [32:1] C;

    // Stage 1: Compute bit‐level propagate and generate signals.
    assign P1 = a ^ b;
    assign G1 = a & b;

    // Stage 2: Combine pairs of bits.
    genvar i;
    generate
      for(i = 0; i < 16; i = i + 1) begin: stage2
         assign G2[i] = G1[2*i] | (P1[2*i] & G1[2*i+1]);
         assign P2[i] = P1[2*i] & P1[2*i+1];
      end
    endgenerate

    // Stage 3: Combine pairs from stage 2.
    generate
      for(i = 0; i < 8; i = i + 1) begin: stage3
         assign G3[i] = G2[2*i] | (P2[2*i] & G2[2*i+1]);
         assign P3[i] = P2[2*i] & P2[2*i+1];
      end
    endgenerate

    // Stage 4: Combine pairs from stage 3.
    generate
      for(i = 0; i < 4; i = i + 1) begin: stage4
         assign G4[i] = G3[2*i] | (P3[2*i] & G3[2*i+1]);
         assign P4[i] = P3[2*i] & P3[2*i+1];
      end
    endgenerate

    // Stage 5: Combine pairs from stage 4.
    generate
      for(i = 0; i < 2; i = i + 1) begin: stage5
         assign G5[i] = G4[2*i] | (P4[2*i] & G4[2*i+1]);
         assign P5[i] = P4[2*i] & P4[2*i+1];
      end
    endgenerate

    // Final stage: Combine the two stage5 signals.
    assign G6 = G5[0] | (P5[0] & G5[1]);
    assign P6 = P5[0] & P5[1];

    // Reduction phase:
    // Compute the “even‐indexed” carries in parallel using the tree.
    assign C[1]  = G1[0]  | (P1[0]  & carry_in);
    assign C[2]  = G2[0]  | (P2[0]  & C[1]);
    assign C[4]  = G3[0]  | (P3[0]  & C[2]);
    assign C[8]  = G4[0]  | (P4[0]  & C[4]);
    assign C[16] = G5[0]  | (P5[0]  & C[8]);
    assign C[32] = G6     | (P6     & C[16]);

    // Expansion phase:
    // Compute the remaining (odd-indexed) carries using the standard lookahead formula.
    assign C[3]  = G1[2]  | (P1[2]  & C[2]);
    assign C[5]  = G1[4]  | (P1[4]  & C[4]);
    assign C[6]  = G2[2]  | (P2[2]  & C[4]);
    assign C[7]  = G1[6]  | (P1[6]  & C[6]);
    assign C[9]  = G1[8]  | (P1[8]  & C[8]);
    assign C[10] = G2[4]  | (P2[4]  & C[8]);
    assign C[11] = G1[10] | (P1[10] & C[10]);
    assign C[12] = G3[2]  | (P3[2]  & C[8]);
    assign C[13] = G1[12] | (P1[12] & C[12]);
    assign C[14] = G2[6]  | (P2[6]  & C[12]);
    assign C[15] = G1[14] | (P1[14] & C[14]);
    assign C[17] = G1[16] | (P1[16] & C[16]);
    assign C[18] = G2[8]  | (P2[8]  & C[16]);
    assign C[19] = G1[18] | (P1[18] & C[18]);
    assign C[20] = G3[4]  | (P3[4]  & C[16]);
    assign C[21] = G1[20] | (P1[20] & C[20]);
    assign C[22] = G2[10] | (P2[10] & C[20]);
    assign C[23] = G1[22] | (P1[22] & C[22]);
    assign C[24] = G4[2]  | (P4[2]  & C[16]);
    assign C[25] = G1[24] | (P1[24] & C[24]);
    assign C[26] = G2[12] | (P2[12] & C[24]);
    assign C[27] = G1[26] | (P1[26] & C[26]);
    assign C[28] = G3[6]  | (P3[6]  & C[24]);
    assign C[29] = G1[28] | (P1[28] & C