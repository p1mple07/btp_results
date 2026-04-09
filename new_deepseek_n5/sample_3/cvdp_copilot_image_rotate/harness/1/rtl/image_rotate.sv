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

  // Generate padded_image
  generate
    for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_block
      for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_block
        case (rotation_angle)
          00: padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH:0] = 0;
          01: padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH:0] = 0;
          10: padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH:0] = 0;
          11: rot_row = pad_row; rot_col = pad_col;
        endcase
      end
    end
  endgenerate

  // Generate transposed_image
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        transposed_image[(trans_row * OUT_COL + trans_col) * DATA_WIDTH:0] = 
          padded_image[(trans_col * OUT_ROW + trans_row) * DATA_WIDTH:0];
      end
    end
  endgenerate

  // Generate rotated_image based on rotation_angle
  case (rotation_angle)
    00: // 90°: transpose and reverse rows
      for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_block
        for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_block
          image_out[(rot_row * OUT_COL + rot_col) * DATA_WIDTH:0] = 
            transposed_image[(rot_col * OUT_ROW + rot_row) * DATA_WIDTH:0];
        end
      end
    01: // 180°: reverse rows and columns
      for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_block
        for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_block
          image_out[(rot_row * OUT_COL + rot_col) * DATA_WIDTH:0] = 
            padded_image[(OUT_ROW - 1 - rot_row) * OUT_COL + (OUT_COL - 1 - rot_col)] * DATA_WIDTH:0];
        end
      end
    10: // 270°: transpose and reverse columns
      for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_block
        for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_block
          image_out[(rot_row * OUT_COL + rot_col) * DATA_WIDTH:0] = 
            transposed_image[(rot_col * OUT_ROW + (OUT_COL - 1 - rot_row)) * DATA_WIDTH:0];
        end
      end
    11: // No rotation
      for (rot_row = 0; rot_row < OUT_ROW; rot_row++) begin: rot_row_block
        for (rot_col = 0; rot_col < OUT_COL; rot_col++) begin: rot_col_block
          image_out[(rot_row * OUT_COL + rot_col) * DATA_WIDTH:0] = 
            padded_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH:0];
        end
      end
  endcase

endmodule