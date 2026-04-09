module prim_max_find #(
  parameter int NumSrc = 8,
  parameter int Width  = 8
) (
  input                         clk_i,
  input                         rst_ni,
  input [Width*NumSrc-1:0]      values_i,    // Flattened input values
  input [NumSrc-1:0]            valid_i,     // Validity bits for each input
  output wire [Width-1:0]       max_value_o, // Maximum value among valid inputs
  output wire [clog2(NumSrc)-1:0] max_idx_o,  // Index of the maximum value
  output wire                   max_valid_o  // Indicates if any input is valid
);

  // Corrected parameters:
  // Use NumLevels = $clog2(NumSrc) + 1 so that level0 is the root,
  // level1 and above are internal nodes, and level (NumLevels-1) are leaves.
  localparam int NumLevels = $clog2(NumSrc) + 1;
  // Total number of nodes in a complete binary tree representation:
  localparam int TotalNodes = 2**NumLevels - 1;

  // The tree arrays are sized to TotalNodes; only the valid indices for each level are used.
  // vld_tree: validity flag for each node.
  reg [TotalNodes-1:0] vld_tree [0:NumLevels-1];
  // idx_tree: stores the original input index corresponding to the maximum value.
  reg [clog2(NumSrc)-1:0] idx_tree [0:NumLevels-1];
  // max_tree: stores the maximum value from the subtree.
  reg [Width-1:0] max_tree [0:NumLevels-1];

  // In a complete binary tree stored in an array with root at index 0:
  // For level L (0-indexed), the starting index is: start_index = 2**L - 1
  // and the number of nodes at that level is: num_nodes = 2**L.
  // Leaves are at level NumLevels-1.
  generate
    for (genvar level = 0; level < NumLevels; level++) begin : gen_level
      localparam int start_index = (2**level) - 1;
      localparam int num_nodes   = 2**level;
      for (genvar i = 0; i < num_nodes; i++) begin : gen_node
        localparam int node_index = start_index + i;
        if (level == NumLevels-1) begin : gen_leaf
          // Leaf nodes: directly capture input value and validity.
          always @(posedge clk_i or negedge rst_ni) begin
            if (!rst_ni) begin
              vld_tree[level][node_index] <= 1'b0;
              idx_tree[level][node_index] <= '0;
              max_tree[level][node_index] <= '0;
            end else begin
              // Note: SystemVerilog part-select syntax [i*Width +: Width]
              vld_tree[level][node_index] <= valid_i[i];
              idx_tree[level][node_index] <= i;
              max_tree[level][node_index] <= values_i[i*Width +: Width];
            end
          end
        end else begin : gen_internal
          // Internal nodes: combine the two child nodes.
          // For a node at index "node_index" at level "level", its children are:
          // left child at index = 2*node_index + 1
          // right child at index = 2*node_index + 2
          always @(posedge clk_i or negedge rst_ni) begin
            if (!rst_ni) begin
              vld_tree[level][node_index] <= 1'b0;
              idx_tree[level][node_index] <= '0;
              max_tree[level][node_index] <= '0;
            end else begin
              if (vld_tree[level+1][2*node_index+1] && vld_tree[level+1][2*node_index+2]) begin
                // Both children are valid: select the one with the greater value.
                if (max_tree[level+1][2*node_index+1] >= max_tree[level+1][2*node_index+2]) begin
                  vld_tree[level][node_index] <= 1'b1;
                  idx_tree[level][node_index] <= idx_tree[level+1][2*node_index+1];
                  max_tree[level][node_index] <= max_tree[level+1][2*node_index+1];
                end else begin
                  vld_tree[level][node_index] <= 1'b1;
                  idx_tree[level][node_index] <= idx_tree[level+1][2*node_index+2];
                  max_tree[level][node_index] <= max_tree[level+1][2*node_index+2];
                end
              end else if (vld_tree[level+1][2*node_index+1]) begin
                // Only left child is valid.
                vld_tree[level][node_index] <= 1'b1;
                idx_tree[level][node_index] <= idx_tree[level+1][2*node_index+1];
                max_tree[level][node_index] <= max_tree[level+1][2*node_index+1];
              end else if (vld_tree[level+1][2*node_index+2]) begin
                // Only right child is valid.
                vld_tree[level][node_index] <= 1'b1;
                idx_tree[level][node_index] <= idx_tree[level+1][2*node_index+2];
                max_tree[level][node_index] <= max_tree[level+1][2*node_index+2];
              end else begin
                // No valid child.
                vld_tree[level][node_index] <= 1'b0;
                idx_tree[level][node_index] <= '0;
                max_tree[level][node_index] <= '0;
              end
            end
          end
        end
      end
    end
  endgenerate

  // The final result is taken from the root of the tree (index 0 at level 0).
  assign max_valid_o = vld_tree[0][0];
  assign max_idx_o   = idx_tree[0][0];
  assign max_value_o = max_tree[0][0];

endmodule