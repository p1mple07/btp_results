module prim_max_find #(
  parameter int NumSrc = 8,
  parameter int Width  = 8,
  // Derived parameters: assume NumSrc is a power of 2.
  localparam int SrcWidth  = $clog2(NumSrc),
  localparam int NumLevels = $clog2(NumSrc) - 1, // Number of internal levels (leaves at level NumLevels)
  localparam int NumNodes  = 2**(NumLevels+1)      // Total nodes in a complete binary tree
) (
  input                         clk_i,
  input                         rst_ni,
  input [Width*NumSrc-1:0]      values_i,    // Flattened vector of input values
  input [NumSrc-1:0]            valid_i,     // Validity bits for each input
  output wire [Width-1:0]       max_value_o, // Maximum value among valid inputs
  output wire [SrcWidth-1:0]    max_idx_o,   // Index of the maximum value
  output wire                   max_valid_o  // Indicates if any input is valid
);

  // Declare tree arrays. Each level has exactly NumNodes entries.
  reg [NumNodes-1:0]                vld_tree [0:NumLevels];
  reg [SrcWidth-1:0]                 idx_tree [0:NumLevels][NumNodes-1:0];
  reg [Width-1:0]                    max_tree [0:NumLevels][NumNodes-1:0];

  // Generate internal nodes (levels 0 to NumLevels-1)
  generate
    for (genvar level = 0; level < NumLevels; level++) begin : gen_internal
      // For a complete binary tree with 0-indexed nodes:
      // - The starting index for level L is (2**L - 1).
      // - There are 2**L nodes at level L.
      // - The parent's index is computed as: Pa = (2**level - 1) + offset.
      // - The children of node Pa are at indices: C0 = (2**(level+1) - 1) + 2*offset,
      //   and C1 = (2**(level+1) - 1) + 2*offset + 1.
      for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
        localparam int Pa   = (2**level) - 1 + offset;
        localparam int C0   = (2**(level+1)) - 1 + 2*offset;
        localparam int C1   = (2**(level+1)) - 1 + 2*offset + 1;

        always @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            vld_tree[level][Pa]   <= 1'b0;
            idx_tree[level][Pa]   <= '0;
            max_tree[level][Pa]   <= '0;
          end else begin
            // Propagate the maximum from the two children.
            // If child C0 is not valid but C1 is, choose C1.
            // If both are valid, select the one with the higher value.
            if ((~vld_tree[level+1][C0]) & vld_tree[level+1][C1]) begin
              vld_tree[level][Pa]   <= vld_tree[level+1][C1];
              idx_tree[level][Pa]   <= idx_tree[level+1][C1];
              max_tree[level][Pa]   <= max_tree[level+1][C1];
            end else if (vld_tree[level+1][C0] & vld_tree[level+1][C1] &
                         (max_tree[level+1][C1] > max_tree[level+1][C0])) begin
              vld_tree[level][Pa]   <= vld_tree[level+1][C1];
              idx_tree[level][Pa]   <= idx_tree[level+1][C1];
              max_tree[level][Pa]   <= max_tree[level+1][C1];
            end else begin
              vld_tree[level][Pa]   <= vld_tree[level+1][C0];
              idx_tree[level][Pa]   <= idx_tree[level+1][C0];
              max_tree[level][Pa]   <= max_tree[level+1][C0];
            end
          end
        end
      end
    end

    // Generate leaf nodes (level = NumLevels)
    // There are exactly NumSrc leaves.
    for (genvar offset = 0; offset < NumSrc; offset++) begin : gen_leafs
      localparam int Pa = (2**(NumLevels)) - 1 + offset;
      always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          vld_tree[NumLevels][Pa]   <= 1'b0;
          idx_tree[NumLevels][Pa]   <= '0;
          max_tree[NumLevels][Pa]   <= '0;
        end else begin
          vld_tree[NumLevels][Pa]   <= valid_i[offset];
          idx_tree[NumLevels][Pa]   <= offset;
          // Correct slicing: extract the slice corresponding to this leaf.
          max_tree[NumLevels][Pa]   <= values_i[(offset+1)*Width-1 : offset*Width];
        end
      end
    end
  endgenerate

  // The root of the tree is now at index 0.
  assign max_valid_o = vld_tree[0][0];
  assign max_idx_o   = idx_tree[0][0];
  assign max_value_o = max_tree[0][0];

endmodule