module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic [                            1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [  (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in      , // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out       // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image    ; // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  // Pad the input image to a square
  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

   always_comb begin
     for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin : pad_row_loop
       for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin : pad_col_loop
         if (pad_row < IN_ROW && pad_col < IN_COL) begin
           assign padded_image[pad_row*OUT_COL + pad_col] = image_in[pad_row*IN_COL + pad_col];
         end else begin
           assign padded_image[pad_row*OUT_COL + pad_col] = 0;
         end
       end
     end
  end

  // Transpose the padded image
  always_comb begin
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin : trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin : trans_col_block
        assign transposed_image[trans_row*OUT_COL + trans_col] = padded_image[trans_col*OUT_ROW + trans_row];
      end
    end
  end

  // Generate the output based on the rotation angle
  case (rotation_angle)
    "00": begin
      image_out = reverse_rows(transposed_image);
    end
    "01": begin
      image_out = reverse_rows(reverse_cols(padded_image));
    end
    "10": begin
      image_out = reverse_cols(reverse_rows(transposed_image));
    end
    "11": begin
      image_out = padded_image;
    end
  endcase

endmodule

// Helper functions to reverse a row or column
always_comb begin
  logic [WIDTH-1:0] reversed = ~value;
end

always_comb begin
  logic [WIDTH-1:0] reversed = ~transposed_image;
  assign image_out = reversed;
end
