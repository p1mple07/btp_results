module image_rotate #(
  parameter IN_ROW     = 4                                  , // Number of rows in input matrix
  parameter IN_COL     = 4                                  , // Number of columns in input matrix
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic [                             1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [  (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in      , // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out       // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image    ; // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // Padded image logic
  for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_block
    for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_block
      if (pad_row < IN_ROW && pad_col < IN_COL) begin: fill_padded
        padded_image[pad_row * OUT_COL + pad_col * DATA_WIDTH + : DATA_WIDTH] = image_in[pad_row * IN_COL + pad_col * DATA_WIDTH + : DATA_WIDTH];
      end else begin: fill_zeros
        padded_image[pad_row * OUT_COL + pad_col * DATA_WIDTH + : DATA_WIDTH] = 0;
      end
    end
  end

  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        transposed_image[trans_row * OUT_COL + trans_col * DATA_WIDTH + : DATA_WIDTH] = padded_image[trans_col * OUT_ROW + trans_row * DATA_WIDTH + : DATA_WIDTH];
      end
    end
  endgenerate

  // Output logic
  case (rotation_angle)
    0b00: begin
      image_out = {transposed_image[OUT_COL - 1 - trans_col * DATA_WIDTH + : DATA_WIDTH], transposed_image[(trans_row + 1) * OUT_COL * DATA_WIDTH + : DATA_WIDTH], transposed_image[(trans_row + 2) * OUT_COL * DATA_WIDTH + : DATA_WIDTH], transposed_image[(trans_row + 3) * OUT_COL * DATA_WIDTH + : DATA_WIDTH]};
    end
    0b01: begin
      image_out = {padded_image[(OUT_ROW - 1 - trans_row * DATA_WIDTH + : DATA_WIDTH), (OUT_COL - 1 - trans_col * DATA_WIDTH + : DATA_WIDTH)], padded_image[(OUT_ROW - 2 - trans_row * DATA_WIDTH + : DATA_WIDTH), (OUT_COL - 2 - trans_col * DATA_WIDTH + : DATA_WIDTH)], padded_image[(OUT_ROW - 3 - trans_row * DATA_WIDTH + : DATA_WIDTH), (OUT_COL - 3 - trans_col * DATA_WIDTH + : DATA_WIDTH)], padded_image[(OUT_ROW - 4 - trans_row * DATA_WIDTH + : DATA_WIDTH), (OUT_COL - 4 - trans_col * DATA_WIDTH + : DATA_WIDTH)]};
    end
    0b10: begin
      image_out = {transposed_image[OUT_ROW - 1 - rot_row * DATA_WIDTH + : DATA_WIDTH], transposed_image[OUT_ROW - 2 - rot_row * DATA_WIDTH + : DATA_WIDTH], transposed_image[OUT_ROW - 3 - rot_row * DATA_WIDTH + : DATA_WIDTH], transposed_image[OUT_ROW - 4 - rot_row * DATA_WIDTH + : DATA_WIDTH]};
    end
    0b11: begin
      image_out = padded_image;
    end
  endcase
endmodule
