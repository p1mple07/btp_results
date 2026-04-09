module prim_max_find #(
  parameter int NumSrc = 8,
  parameter int Width  = 8,
  // Compute source index width
  localparam int SrcWidth = $clog2(NumSrc),
  // Number of levels: leaves are at level NumLevels.
  // For a complete binary tree with NumSrc leaves, we need:
  //   NumLevels = log2(NumSrc)   and total nodes = 2**(NumLevels+1) - 1.
  localparam int NumLevels = $clog2(NumSrc),
  localparam int NumNodes  = (2**(NumLevels+1) - 1)
) (
  input                         clk_i,
  input                         rst_ni,
  input [Width*NumSrc-1:0]      values_i,    // Flattened input values
  input [NumSrc-1:0]            valid_i,     // Validity bits for each input
  output reg [Width-1:0]        max_value_o, // Maximum value among valid inputs
  output reg [SrcWidth-1:0]     max_idx_o,   // Index of the maximum value
  output reg                    max_valid_o  // Flag indicating if any input is valid
);

  // Internal registers for the binary tree:
  // Each node holds a validity flag, the index of the valid input, and the maximum value.
  reg                           vld [0:NumNodes-1];
  reg [SrcWidth-1:0]            idx [0:NumNodes-1];
  reg [Width-1:0]               max_val [0:NumNodes-1];

  //-------------------------------------------------------------------------
  // Generate Leaves: These correspond to the actual inputs.
  // Leaves are located at level = NumLevels.
  // For a complete binary tree, the starting index for level L is (2**L - 1).
  //-------------------------------------------------------------------------
  generate
    for (genvar offset = 0; offset < 2**NumLevels; offset++) begin : gen_leaf
      localparam int leaf_index = (2**NumLevels - 1) + offset;
      always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          vld[leaf_index]   <= 1'b0;
          idx[leaf_index]   <= '0;
          max_val[leaf_index] <= '0;
        end else begin
          if (offset < NumSrc) begin
            vld[leaf_index]   <= valid_i[offset];
            idx[leaf_index]   <= offset;
            max_val[leaf_index] <= values_i[(offset+1)*Width-1 -: Width];
          end else begin
            // Tie-off unused leaves
            vld[leaf_index]   <= 1'b0;
            idx[leaf_index]   <= '0;
            max_val[leaf_index] <= '0;
          end
        end
      end
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Generate Internal Nodes: Combine the results from child nodes.
  // For each internal node at level L (0 <= L < NumLevels), the parent node is
  // located at index = (2**L - 1) + offset, with 2**L nodes at that level.
  // Its children are at indices:
  //   left_child  = (2**(L+1) - 1) + (2*offset)
  //   right_child = (2**(L+1) - 1) + (2*offset) + 1
  //-------------------------------------------------------------------------
  generate
    for (genvar level = 0; level < NumLevels; level++) begin : gen_internal
      for (genvar offset = 0; offset < 2**level; offset++) begin : gen_node
        localparam int parent_index  = (2**level - 1) + offset;
        localparam int left_child    = (2**(level+1) - 1) + (2*offset);
        localparam int right_child   = (2**(level+1) - 1) + (2*offset) + 1;
        always @(posedge clk_i or negedge rst_ni) begin
          if (!rst_ni) begin
            vld[parent_index]   <= 1'b0;
            idx[parent_index]   <= '0;
            max_val[parent_index] <= '0;
          end else begin
            // Propagate the valid bit and select the maximum value.
            if (vld[left_child] && vld[right_child]) begin
              if (max_val[right_child] > max_val[left_child]) begin
                vld[parent_index]   <= 1'b1;
                idx[parent_index]   <= idx[right_child];
                max_val[parent_index] <=