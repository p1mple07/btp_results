
module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic                                    clk,
  input  logic                                    srst,
  input  logic                                    valid_in,
  input  logic                       [       1:0] rotation_angle,
  input  logic   [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic                                    valid_out,
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  // Internal signals
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated;

  // Compute padded and rotated image in one combinational block
  always_comb begin
    // Pad image: create square image with zeros outside original bounds
    for (int row = 0; row < OUT_ROW; row++) begin
      for (int col = 0; col < OUT_COL; col++) begin
        if (row < IN_ROW && col < IN_COL)
          padded[(row * OUT_COL + col) * DATA_WIDTH +: DATA_WIDTH] = image_in[(row * IN_COL + col) * DATA_WIDTH +: DATA_WIDTH];
        else
          padded[(row * OUT_COL + col) * DATA_WIDTH +: DATA_WIDTH] = '0;
      end
    end

    // Apply rotation logic directly on padded image
    for (int rot_row = 0; rot_row < OUT_ROW; rot_row++) begin
      for (int rot_col = 0; rot_col < OUT_COL; rot_col++) begin
        case (rotation_angle)
          2'b00: // 90° Clockwise: Transpose + Reverse Columns
            rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = padded[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];
          2'b01: // 180° Clockwise: Reverse Rows and Columns
            rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = padded[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];
          2'b10: // 270° Clockwise: Transpose + Reverse Rows
            rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = padded[((OUT_ROW-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
          2'b11: // No Rotation
            rotated[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = padded[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
        endcase
      end
    end
  end

  // Register the outputs (one register stage)
  always_ff @(posedge clk or posedge srst) begin
    if (srst) begin
      image_out <= '0;
      valid_out <= 1'b0;
    end else begin
      image_out <= rotated;
      valid_out <= valid_in; // valid_out is now one cycle delayed
    end
  end

endmodule
