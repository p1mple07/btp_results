module brent_kung_adder(
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic        carry_in,
    output logic [31:0] sum,
    output logic        carry_out
);

  // Stage 1: Compute propagate and generate signals for each bit.
  logic [31:0] P1, G1;
  assign P1 = a ^ b;
  assign G1 = a & b;

  //-------------------------------------------------------------------------
  // Stage 2: Pair-reduce the 32 bits into 16 groups.
  // For each group i, use bits [2*i] and [2*i+1]:
  //   G2[i] = G1[2*i] OR (P1[2*i] AND G1[2*i+1])
  //   P2[i] = P1[2*i] AND P1[2*i+1]
  //-------------------------------------------------------------------------
  logic [15:0] P2, G2;
  genvar i;
  generate
    for (i = 0; i < 16; i = i + 1) begin : stage2
      assign G2[i] = G1[2*i] | (P1[2*i] & G1[2*i+1]);
      assign P2[i] = P1[2*i] & P1[2*i+1];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Stage 3: Reduce the 16 groups into 8 groups.
  // For each group i, use groups [2*i] and [2*i+1]:
  //   G3[i] = G2[2*i] OR (P2[2*i] AND G2[2*i+1])
  //   P3[i] = P2[2*i] AND P2[2*i+1]
  //-------------------------------------------------------------------------
  logic [7:0] P3, G3;
  generate
    for (i = 0; i < 8; i = i + 1) begin : stage3
      assign G3[i] = G2[2*i] | (P2[2*i] & G2[2*i+1]);
      assign P3[i] = P2[2*i] & P2[2*i+1];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Stage 4: Reduce the 8 groups into 4 groups.
  // For each group i, use groups [2*i] and [2*i+1]:
  //   G4[i] = G3[2*i] OR (P3[2*i] AND G3[2*i+1])
  //   P4[i] = P3[2*i] AND P3[2*i+1]
  //-------------------------------------------------------------------------
  logic [3:0] P4, G4;
  generate
    for (i = 0; i < 4; i = i + 1) begin : stage4
      assign G4[i] = G3[2*i] | (P3[2*i] & G3[2*i+1]);
      assign P4[i] = P3[2*i] & P3[2*i+1];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Stage 5: Reduce the 4 groups into 2 groups.
  // For each group i, use groups [2*i] and [2*i+1]:
  //   G5[i] = G4[2*i] OR (P4[2*i] AND G4[2*i+1])
  //   P5[i] = P4[2*i] AND P4[2*i+1]
  //-------------------------------------------------------------------------
  logic [1:0] P5, G5;
  generate
    for (i = 0; i < 2; i = i + 1) begin : stage5
      assign G5[i] = G4[2*i] | (P4[2*i] & G4[2*i+1]);
      assign P5[i] = P4[2*i] & P4[2*i+1];
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Stage 6: Final reduction to obtain the overall generate and propagate.
  // Combine the two final groups:
  //   G6 = G5[0] OR (P5[0] AND G5[1])
  //   P6 = P5[0] AND P5[1]
  //-------------------------------------------------------------------------
  logic G6, P6;
  assign G6 = G5[0] | (P5[0] & G5[1]);
  assign P6 = P5[0] & P5[1];

  //-------------------------------------------------------------------------
  // Build the carry tree.
  // We use a tree structure that propagates the carry_in through the levels.
  // Level 1: For each bit i, compute:
  //   C[2*i+1] = G1[2*i] OR (P1[2*i] AND C[2*i])
  // Level 2: For each group i, compute:
  //   C[4*i+2] = G2[i] OR (P2[i] AND C[4*i+1])
  // Level 3: For each group i, compute:
  //   C[8*i+4] = G3[i] OR (P3[i] AND C[8*i+2])
  // Level 4: For each group i, compute:
  //   C[16*i+8] = G4[i] OR (P4[i] AND C[16*i+4])
  // Level 5: Final stage: combine the two remaining groups.
  //   The final carry out is given by:
  //   carry_out = G6 OR (P6 AND C[16])
  //-------------------------------------------------------------------------
  logic [32:0] C;  // C[0] is the input carry; C[32] is the final carry out.
  assign C[0] = carry_in;

  // Level 1: Process bit pairs from stage 1.
  generate
    for (i = 0; i < 16; i = i + 1) begin : level1
      assign C[2*i+1] = G1[2*i] | (P1[2*i] & C[2*i]);
    end
  endgenerate

  // Level 2: Process groups from stage 2.
  generate
    for (i = 0; i < 8; i = i + 1) begin : level2
      assign C[4*i+2] = G2[i] | (P2[i] & C[4*i+1]);
    end
  endgenerate

  // Level 3: Process groups from stage 3.
  generate
    for (i = 0; i < 4; i = i + 1) begin : level3
      assign C[8*i+4] = G3[i] | (P3[i] & C[8*i+2]);
    end
  endgenerate

  // Level 4: Process groups from stage 4.
  generate
    for (i = 0; i < 2; i = i + 1) begin : level4
      assign C[16*i+8] = G4[i] | (P4[i] & C[16*i+4]);
    end
  endgenerate

  // Level 5: Final stage.
  // The final carry out is computed by combining the last two groups.
  // Note: C[16] is available from level 4.
  assign C[32] = G6 | (P6 & C[16]);

  //-------------------------------------------------------------------------
  // Compute the sum.
  // The sum is given by the propagate signal OR the concatenation of the
  // carry outputs (excluding the final carry out) with the input carry.
  //-------------------------------------------------------------------------
  assign sum = P1 | {C[31:1], carry_in};
  assign carry_out = C[32];

endmodule