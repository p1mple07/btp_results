module prim_max_find #(
  parameter int NumSrc = 8,
  parameter int Width = 8,
  // Derived parameters: use "Levels" to denote the total number of levels (0 = root, Levels-1 = leaves)
  localparam int SrcWidth = $clog2(NumSrc),
  localparam int Levels   = $clog2(NumSrc),
  // Total nodes in a complete binary tree with "Levels" levels is 2**Levels - 1
  localparam int NumNodes = 2**Levels - 1
) (
  input                         clk_i,
  input                         rst_ni,
  input [Width*NumSrc-1:0]      values_i,    // Flattened input values: each source occupies [offset*Width +: Width]
  input [NumSrc-1:0]            valid_i,     // Validity bits for each source
  output wire [Width-1:0]       max_value_o, // Maximum value among valid inputs
  output wire [SrcWidth-1:0]    max_idx_o,   // Index of the maximum value
  output wire                   max_valid_o  // Indicates if any input is valid
);

  // Tree arrays: each level is indexed from 0 to (2**level - 1)
  reg [NumNodes-1:0]                vld_tree [0:Levels];
  reg [SrcWidth-1:0]                 idx_tree [0:Levels][NumNodes-1:0];
  reg [Width-1:0]                    max_tree [0:Levels][NumNodes-1:0];

  generate
    // Loop over levels: level 0 is the root; level Levels-1 are the leaves.
    for (genvar level = 0; level < Levels; level++) begin : gen_tree
      // Correct the base addresses for a binary heap-style indexing:
      // For level L, valid indices run from (2**L - 1) to (2**(L+1) - 2)
      localparam int Base0 = (2**level - 1);
      localparam int Base1 = (2**(level+1) - 1);

      // For each node at this level, there are 2**level nodes.
      for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
        localparam int Pa = Base0 + offset;
        // Children of node Pa are located at indices:
        localparam int C0 = Base1 + 2*offset;
        localparam int C1 = Base1 + 2*offset + 1;

        if (level == Levels - 1) begin : gen_leafs
          if (offset < NumSrc) begin : gen_assign
            always @(posedge clk_i or negedge rst_ni) begin
              if (!rst_ni) begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= '0;
                max_tree[level][Pa] <= '0;
              end else begin
                // Extract the correct slice for the i-th source.
                vld_tree[level][Pa] <= valid_i[offset];
                idx_tree[level][Pa] <= offset;
                max_tree[level][Pa] <= values_i[offset*Width +: Width];
              end
            end
          end else begin : gen_tie_off
            always @(posedge clk_i or negedge rst_ni) begin
              if (!rst_ni) begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= '0;
                max_tree[level][Pa] <= '0;
              end
            end
          end
        end else begin : gen_nodes
          reg sel;
          always @(posedge clk_i or negedge rst_ni) begin
            if (!rst_ni) begin
              vld_tree[level][Pa] <= 1'b0;
              idx_tree[level][Pa] <= '0;
              max_tree[level][Pa] <= '0;
            end else begin
              // Select the child with the valid (and, if both valid, the greater) value.
              sel = (~vld_tree[level+1][C0] & vld_tree[level+1][C1]) |
                    (vld_tree[level+1][C0] & vld_tree[level+1][C1] & (max_tree[level+1][C1] > max_tree[level+1][C0]));

              vld_tree[level][Pa] <= (sel) ? vld_tree[level+1][C1] : vld_tree[level+1][C0];
              idx_tree[level][Pa] <= (sel) ? idx_tree[level+1][C1] : idx_tree[level+1][C0];
              max_tree[level][Pa] <= (sel) ? max_tree[level+1][C1] : max_tree[level+1][C0];
            end
          end
        end
      end : gen_level
    end : gen_tree
  endgenerate

  // The final maximum is obtained from the root (level 0, index 0)
  assign max_valid_o = vld_tree[0][0];
  assign max_idx_o   = idx_tree[0][0];
  assign max_value_o = max_tree[0][0];

endmodule