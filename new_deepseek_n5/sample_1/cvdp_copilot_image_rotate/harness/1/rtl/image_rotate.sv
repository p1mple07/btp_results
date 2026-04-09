module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input logic[1:0] rotation_angle,
  input logic[(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic[(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;

  genvar pad_row, pad_col, trans_row, trans_col;

  // Padding logic
  generate
    for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_block
      for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_block
        if (pad_row < IN_ROW && pad_col < IN_COL) begin
          padded_image[pad_row * OUT_COL + pad_col] = image_in[pad_row * IN_COL + pad_col];
        else begin
          padded_image[pad_row * OUT_COL + pad_col] = 0;
        end
      end
    end
  endgenerate

  // Transpose logic
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        transposed_image[trans_row * OUT_COL + trans_col] = padded_image[trans_col * OUT_ROW + trans_row];
      end
    end
  endgenerate

  // Rotation logic
  case (rotation_angle)
    00: image_out = transposed_image;
    01: begin
      image_out = padded_image;
      for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: rot_row_block
        for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: rot_col_block
          image_out[trans_row * OUT_COL + trans_col] = padded_image[(OUT_ROW - 1 - trans_row) * OUT_COL + trans_col];
        end
      end
    end
    10: begin
      image_out = padded_image;
      for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: rot_row_block
        for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: rot_col_block
          image_out[trans_row * OUT_COL + trans_col] = padded_image[trans_row * OUT_COL + (OUT_COL - 1 - trans_col)];
        end
      end
    end
    11: image_out = padded_image;
  endcase

endmodule