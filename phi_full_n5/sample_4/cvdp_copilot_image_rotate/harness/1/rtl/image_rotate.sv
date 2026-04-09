module image_rotate #(
  parameter IN_ROW     = 4                                  ,
  parameter IN_COL     = 4                                  ,
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic [ 1:0] rotation_angle,
  input  logic [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image;

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // Padded image logic
  for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_block
    for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_block
      padded_image[pad_row * OUT_COL + pad_col] = 1'b0;
    end
  end

  for (pad_row = 0; pad_row < IN_ROW; pad_row++) begin: pad_row_block
    for (pad_col = 0; pad_col < IN_COL; pad_col++) begin: pad_col_block
      padded_image[pad_row * OUT_COL + pad_col] = image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH + : DATA_WIDTH];
    end
  end

  // Transposed image logic
  for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
    for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
      transposed_image[trans_row * OUT_COL + trans_col] = padded_image[trans_row * IN_COL + trans_col];
    end
  end

  // Output logic
  always_comb begin
    case (rotation_angle)
      2'b00: image_out = transposed_image;
      2'b01: begin
        image_out = {{(OUT_ROW - 1) * OUT_COL * DATA_WIDTH - 1, padded_image}};
        image_out = {{(OUT_ROW - 1) * OUT_COL * DATA_WIDTH - 1, image_out}};
      end
      2'b10: image_out = {transposed_image};
      2'b11: image_out = padded_image;
    endcase
  end

endmodule
