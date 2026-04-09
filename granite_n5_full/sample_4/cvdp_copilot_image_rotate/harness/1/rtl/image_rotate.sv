module image_rotate #(
  parameter IN_ROW     = 4                                 , // Number of rows in input matrix
  parameter IN_COL     = 4                                 , // Number of columns in input matrix
  parameter OUT_ROW    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL)? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic [                            1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [  (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in     , // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out       // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image    ; // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

   // Padding logic
   assign padded_image = {image_in[((IN_ROW-1)*IN_COL)*DATA_WIDTH+:DATA_WIDTH], image_in};


  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        // Transpose logic
        assign transposed_image[(trans_row*(OUT_COL)) + trans_col] = padded_image[(trans_col*(IN_ROW)) + trans_row];
      end
    end
  endgenerate


   
  // Output logic
  always_comb begin
    case(rotation_angle)
      2'b00: image_out = transposed_image; // 90° Clockwise
      2'b01: image_out = padded_image;      // 180° Clockwise
      2'b10: image_out = $reverse(transposed_image); // 270° Clockwise
      2'b11: image_out = padded_image;      // No Rotation
    endcase
  end

endmodule