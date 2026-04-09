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

   always_comb
   begin
     for (pad_row = 0; pad_row < OUT_ROW; pad_row++)
       begin
         for (pad_col = 0; pad_col < OUT_COL; pad_col++)
           begin
             if ((pad_row < IN_ROW) && (pad_col < IN_COL))
               padded_image[pad_row*OUT_COL + pad_col] = image_in[(pad_row + IN_ROW%2)*IN_COL + (pad_col + IN_COL%2)];
             else
               padded_image[pad_row*OUT_COL + pad_col] = {DATA_WIDTH{1'b0}};
           end
       end
   end


   
  always_comb
  begin
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++)
      begin
        for (trans_col = 0; trans_col < OUT_COL; trans_col++)
          begin
            transposed_image[trans_row*OUT_COL + trans_col] = padded_image[trans_col*IN_ROW + (OUT_ROW-1-trans_row)];
          end
      end
  end


  always_comb
  case (rotation_angle)
    2'd00: image_out = transposed_image;
    2'd01: image_out = {{(OUT_ROW*OUT_COL*DATA_WIDTH){1'b0}}, transposed_image};
    2'd10: image_out = padded_image;
    2'd11: image_out = image_in;
    default: image_out = {OUT_ROW*OUT_COL*DATA_WIDTH{1'b0}};
  endcase

endmodule