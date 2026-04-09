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

  // Padding logic
  initial begin
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        padded_image[trans_row * OUT_COL + trans_col] = 1'b0;
      end
    end
  endgenerate

  // Transpose logic
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        transposed_image[trans_row * OUT_COL + trans_col] = padded_image[trans_col * OUT_ROW + trans_row];
      end
    end
  endgenerate

  // Output logic
  always @(*) begin
    if (rotation_angle == 00) begin
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated;
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          rotated[i*OUT_COL + j] = transposed_image[j * OUT_ROW + i];
        end
      end
    end else if (rotation_angle == 01) begin
      // 180°: reverse rows and columns using padded_image
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] reversed;
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          reversed[i*OUT_COL + j] = ~padded_image[i*OUT_COL + j];
        end
      end
      image_out = reversed;
    end else if (rotation_angle == 10) begin
      // 270°: use transposed_image and reverse columns
      logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] rotated;
      for (i = 0; i < OUT_ROW; i++) begin
        for (j = 0; j < OUT_COL; j++) begin
          rotated[i*OUT_COL + j] = transposed_image[(OUT_COL-1-j)*OUT_ROW + i];
        end
      end
    end else if (rotation_angle == 11) begin
      // No rotation: pass through the padded_image
      image_out = padded_image;
    end else begin
      // Default case
      image_out = padded_image;
    end
  end

endmodule
