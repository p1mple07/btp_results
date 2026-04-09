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

  // Padding logic
  assign {padded_image[pad_row*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH], 0} = image_in[trans_row*IN_COL*DATA_WIDTH + trans_col*DATA_WIDTH +: DATA_WIDTH];
  for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin
    assign {padded_image[(pad_row+1)*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH], 0} = 0;
  end
  for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
    assign {padded_image[pad_row*OUT_COL*DATA_WIDTH + 0*DATA_WIDTH +: DATA_WIDTH], 0} = 0;
    for (pad_col = 1; pad_col < OUT_COL; pad_col++) begin
      assign {padded_image[pad_row*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH], 0} = 0;
    end
  end

  // Transpose logic
  assign {transposed_image[trans_row*OUT_COL*DATA_WIDTH + trans_col*DATA_WIDTH +: DATA_WIDTH], 0} = padded_image[pad_row*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH];

  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        assign {image_out[trans_row*OUT_COL*DATA_WIDTH + trans_col*DATA_WIDTH +: DATA_WIDTH], 0} = transposed_image[trans_row*OUT_COL*DATA_WIDTH + trans_col*DATA_WIDTH +: DATA_WIDTH];
      end
    end
  endgenerate

endmodule
