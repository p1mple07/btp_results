module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input logic [1:0] rotation_angle,
  input logic [ (IN_ROW*IN_COL*DATA_WIDTH)-1:0 ] image_in,
  output logic [ (OUT_ROW*OUT_COL*DATA_WIDTH)-1:0 ] image_out
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // Initialize padded_image with zeros and copy input image
  pad_row = 0;
  pad_col = 0;
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        if (trans_row < IN_ROW & trans_col < IN_COL)
          padded_image[ trans_row * OUT_COL + trans_col ] = image_in[ trans_row * IN_COL + trans_col ];
        else
          padded_image[ trans_row * OUT_COL + trans_col ] = 0;
        end
      end
    end
  endgenerate

  // Transpose the padded_image to get transposed_image
  trans_row = 0;
  trans_col = 0;
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        transposed_image[ trans_row * OUT_COL + trans_col ] = padded_image[ trans_col * OUT_ROW + trans_row ];
      end
    end
  endgenerate

  // Rotate based on rotation_angle
  rot_row = 0;
  rot_col = 0;
  case (rotation_angle)
    00: // 90°
      rot_row = OUT_ROW - 1 - trans_row;
      rot_col = trans_col;
    01: // 180°
      rot_row = OUT_ROW - 1 - trans_row;
      rot_col = OUT_COL - 1 - trans_col;
    10: // 270°
      rot_row = trans_row;
      rot_col = OUT_COL - 1 - trans_col;
    11: // No rotation
      rot_row = trans_row;
      rot_col = trans_col;
  endcase

  // Assign rotated values to image_out
  generate
    for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_block
      for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_block
        image_out[ rot_row * OUT_COL + rot_col ] = transposed_image[ rot_row * OUT_COL + rot_col ];
      end
    end
  endgenerate
endmodule