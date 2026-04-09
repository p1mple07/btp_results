module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic [                             1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [  (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in      , // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out       // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image    ; // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // Pad the image
  always_comb begin
    for (pad_row = 0; pad_row < OUT_ROW - IN_ROW; pad_row++) begin : pad_row_block
      for (pad_col = 0; pad_col < OUT_COL - IN_COL; pad_col++) begin : pad_col_block
        assign padded_image[pad_row*OUT_COL + pad_col] = image_in[pad_row*IN_COL + pad_col];
      end
    end
  end

  // Transpose
  always_comb begin
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin : trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin : trans_col_block
        transposed_image[trans_row*OUT_COL + trans_col] = padded_image[trans_col*IN_ROW + trans_row];
      end
    end
  end

  // Rotate
  case (rotation_angle)
    9'd00: begin
      // 90° clockwise: transposed_image with reverse rows
      for (row = 0; row < OUT_ROW; row++) begin : rotate90_row
        for (col = 0; col < OUT_COL; col++) begin : rotate90_col
          assign transposed_image[row*OUT_COL + col] = transposed_image[(OUT_ROW - 1 - col)*OUT_COL + row];
        end
      end
    end
    9'd01: begin
      // 180°: reverse rows and columns using padded_image
      for (row = 0; row < OUT_ROW; row++) begin : rotate180_row
        for (col = 0; col < OUT_COL; col++) begin : rotate180_col
          assign transposed_image[row*OUT_COL + col] = padded_image[col*OUT_COL + row];
        end
      end
    end
    9'd10: begin
      // 270°: transposed_image and reverse columns
      for (row = 0; row < OUT_ROW; row++) begin : rotate270_row
        for (col = 0; col < OUT_COL; col++) begin : rotate270_col
          assign transposed_image[row*OUT_COL + col] = transposed_image[col*OUT_COL + row];
        end
      end
    end
    default: begin
      // No rotation: pass through
      image_out = padded_image;
    end
  endcase

  // Assign final output
  assign image_out = transposed_image;

endmodule
