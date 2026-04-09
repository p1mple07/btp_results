module prim_max_find #(
  parameter int NumSrc = 8,
  parameter int Width = 8,
  // Derived parameters
  localparam int NumLevels = $clog2(NumSrc);  // Corrected to use NumSrc instead of NumSrc-1
  localparam int NumNodes = (2 ** (NumLevels + 1)) - 1;  // Corrected to use NumLevels+1
  localparam int SWidth = $clog2(NumSrc) - 1,
  localparam int NumLevels = $clog2(NumSrc) - 1,
  localparam int NumNodes = 2 ** (NumLevels + 1) - 1,
  localparam int NumNodes-1:0) ( // Corrected to use NumNodes-1:0
  reg [NumNodes-1:0] vld_tree [0:NumLevels] [0:NumNodes-1]  // Corrected to use NumNodes-1
  reg [SWidth-1:0] idx_tree [0:NumLevels][NumNodes-1:0];
  reg sel; 
  always @(posedge clk_i or negedge rst_ni) begin : genvar
    for (genvar level = 0; level <= NumLevels; level++) begin : genvar
      localparam int Base0 = (2 ** level);
      localparam int Base1 = (2 ** (level + 1));

      for (genvar offset = 0; offset < 2 ** level; offset++) begin : genvar
        localparam int Pa = Base0 + offset;
        localparam int C0 = Base1 + 2 * offset;
        localparam int C1 = Base1 + 2 * offset + 1;

        if (level == NumLevels) begin : genvar
          if (offset < NumSrc) begin : genvar
            always @(posedge clk_i or negedge rst_ni) begin
              if (!rst_ni) begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= 0;
                max_tree[level][Pa] <= values_i[(offset+1)*Width : offset*Width];
              end else begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= 0;
              end
            end
          end else begin : genvar
            always @(posedge clk_i or negedge rst_ni) begin
              if (!rst_ni) begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= 0;
              end else begin
                vld_tree[level][Pa] <= 1'b0;
                idx_tree[level][Pa] <= 0;
              end
            end
          end
        end else begin : genvar
          sel = (~vld_tree[level+1][C1] & vld_tree[level+1][C0] & (max_tree[level+1][C1] > max_tree[level+1][C0]));
          vld_tree[level][Pa] <= (sel) ? vld_tree[level+1][C1] : vld_tree[level+1][C0];
          idx_tree[level][Pa] <= (sel) ? idx_tree[level+1][C1] : idx_tree[level+1][C0];
          max_tree[level][Pa] <= (sel) ? max_tree[level+1][C1] : max_tree[level+1][C0];
        end
      end : genvar
    end : genvar
  end : genvar
  assign max_valid_o = (max_tree[0][0] & 1'b1);
  assign max_idx_o   = idx_tree[0][0];
  assign max_value_o = max_tree[0][0];
  assign max_valid_o = (max_tree[0][0] & 1'b1);
  assign max_idx_o   = idx_tree[0][0];
  assign max_value_o = max_tree[0][0];
endmodule