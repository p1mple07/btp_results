module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input logic [ (IN_ROW*IN_COL*DATA_WIDTH)-1:0 ] image_in,
  input logic [ (OUT_ROW*OUT_COL*DATA_WIDTH)-1:0 ] image_out
);

  logic [ (OUT_ROW*OUT_COL*DATA_WIDTH)-1:0 ] padded_image;
  logic [ (OUT_ROW*OUT_COL*DATA_WIDTH)-1:0 ] transposed_image;

  genvar pad_row, pad_col, trans_row, trans_col;

  // Fill padded_image with zeros and copy from image_in
  generate
    for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_loop
      for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_loop
        if (pad_row < IN_ROW && pad_col < IN_COL) begin
          padded_image[ pad_row * OUT_COL + pad_col ] = image_in[ pad_row * IN_COL + pad_col ];
        else begin
          padded_image[ pad_row * OUT_COL + pad_col ] = 0;
        end
      end
    end
  endgenerate

  // Transpose padded_image to get transposed_image
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_loop
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_loop
        transposed_image[ trans_row * OUT_COL + trans_col ] = padded_image[ trans_col * OUT_COL + trans_row ];
      end
    end
  endgenerate

  // Rotate based on rotation_angle
  case (rotation_angle)
    3 => // 90°
      generate
        for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_loop
          for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_loop
            image_out[ rot_row * OUT_COL + rot_col ] = transposed_image[ (OUT_ROW - 1 - rot_row) * OUT_COL + rot_col ];
          end
        end
      endgenerate
    2 => // 180°
      generate
        for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_loop
          for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_loop
            image_out[ rot_row * OUT_COL + rot_col ] = padded_image[ (OUT_ROW - 1 - rot_row) * OUT_COL + (OUT_COL - 1 - rot_col) ];
          end
        end
      endgenerate
    1 => // 270°
      generate
        for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_loop
          for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_loop
            image_out[ rot_row * OUT_COL + rot_col ] = transposed_image[ rot_row * OUT_COL + (OUT_COL - 1 - rot_col) ];
          end
        end
      endgenerate
    0 => // No rotation
      generate
        for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_loop
          for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_loop
            image_out[ rot_row * OUT_COL + rot_col ] = padded_image[ rot_row * OUT_COL + rot_col ];
          end
        end
      endgenerate
  endcase
endmodule