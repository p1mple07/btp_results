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

  // Padding logic
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  for (int i = 0; i < OUT_ROW; i++) begin : row_loop
    for (int j = 0; j < OUT_COL; j++) begin : col_loop
      if (i < IN_ROW && j < IN_COL) begin
        padded_image[i*OUT_COL + j] = image_in[i*IN_COL + j];
      end else begin
        padded_image[i*OUT_COL + j] = 0;
      end
    end
  end

  // Transpose logic
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;
  for (int i = 0; i < OUT_ROW; i++) begin
    for (int j = 0; j < OUT_COL; j++) begin
      transposed_image[j*OUT_ROW + i] = padded_image[i*OUT_COL + j];
    end
  end

  // Rotation logic
  always @(*) begin
    case (rotation_angle)
      00: // 90°
        begin
          for (int i = 0; i < OUT_ROW; i++) begin
            for (int j = OUT_COL-1; j >= 0; j--) begin
              output_data[i*OUT_COL + j] = transposed_image[j];
            end
          end
        end
      01: // 180°
        begin
          for (int i = 0; i < OUT_ROW; i++) begin
            for (int j = 0; j < OUT_COL; j++) begin
              output_data[i*OUT_COL + j] = padded_image[OUT_ROW-1-i*OUT_COL + j];
            end
          end
        end
      10: // 270°
        begin
          for (int i = 0; i < OUT_ROW; i++) begin
            for (int j = 0; j < OUT_COL; j++) begin
              output_data[i*OUT_COL + j] = transposed_image[j*OUT_ROW + i];
            end
          end
        end
      11: // No Rotation
        begin
          output_data = padded_image;
        end
    endcase
  end

endmodule
