
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
      padded_image[pad_row * OUT_COL * DATA_WIDTH + pad_col * DATA_WIDTH +: DATA_WIDTH] = 0;
    end
  end

  assign image_in = {(IN_ROW * IN_COL) * DATA_WIDTH -1{image_in[IN_ROW * IN_COL * DATA_WIDTH - 1]}, image_in};

  // Transposed image logic
  for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
    for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
      transposed_image[trans_row * OUT_COL * DATA_WIDTH + trans_col * DATA_WIDTH +: DATA_WIDTH] = 
        padded_image[(trans_row + trans_col) * OUT_COL + pad_col * DATA_WIDTH +: DATA_WIDTH];
    end
  end

  // Output logic
  case (rotation_angle)
    0b00: begin
      image_out = {(OUT_COL * OUT_ROW) * DATA_WIDTH -1{transposed_image[OUT_ROW - 1 * DATA_WIDTH - 1]}, transposed_image};
    end
    0b01: begin
      image_out = {(OUT_COL * OUT_ROW) * DATA_WIDTH -1{padded_image[IN_ROW - 1 * DATA_WIDTH - 1]}, padded_image};
    end
    0b10: begin
      image_out = {(OUT_COL * OUT_ROW) * DATA_WIDTH -1{transposed_image[OUT_COL - 1 * DATA_WIDTH - 1]}, transposed_image};
    end
    0b11: begin
      image_out = image_in;
    end
  endcase

endmodule
