module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_COL : IN_ROW,
  parameter DATA_WIDTH = 8
) (
  input  logic [                          1:0] rotation_angle, // 00:90, 01:180, 10:270, 11:no rotation
  input  logic [  (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in      , // flattened input
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out       // flattened output
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image    ; // padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // transposed

  // Padding logic
  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  generate
    for (pad_row in 0 to (OUT_ROW - IN_ROW)) begin: pad_row_block
      for (pad_col in 0 to (OUT_COL - IN_COL)) begin: pad_col_block
        assign padded_image[pad_row*OUT_COL + pad_col] = image_in[pad_row*IN_COL + pad_col];
        // Fill rest with zeros
        for (i in 0 to (OUT_ROW - 1)) begin
          for (j in 0 to (OUT_COL - 1)) begin
            if (i == pad_row && j == pad_col) continue;
            padded_image[i*OUT_COL + j] = padded_image[pad_row*OUT_COL + pad_col];
          end
        end
      end
    end
  endgenerate

  // Transpose logic
  for (trans_row in 0 to (OUT_ROW - 1)) begin
    for (trans_col in 0 to (OUT_COL - 1)) begin: trans_col_block
      assign transposed_image[trans_row*OUT_COL + trans_col] = padded_image[trans_col*OUT_ROW + trans_row];
    end
  endgenerate

  // Output logic
  always @(*) begin
    if (rotation_angle == 00) begin // 90°
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          image_out[i*OUT_COL + j] = transposed_image[j*OUT_ROW + i];
        end
      end
    end else if (rotation_angle == 01) begin // 180°
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          image_out[i*OUT_COL + j] = padded_image[(OUT_COL - 1 - j)*OUT_ROW + (OUT_ROW - 1 - i)];
        end
      end
    end else if (rotation_angle == 10) begin // 270°
      for (j = 0; j < OUT_COL; j++) begin
        for (i = 0; i < OUT_ROW; i++) begin
          image_out[i*OUT_COL + j] = transposed_image[(OUT_ROW - 1 - i)*OUT_COL + (OUT_COL - 1 - j)];
        end
      end
    end else if (rotation_angle == 11) begin // no rotation
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          image_out[i*OUT_COL + j] = padded_image[i*OUT_COL + j];
        end
      end
    end
  end

endmodule
