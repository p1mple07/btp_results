module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
  parameter OUT_ROW    = (IN_ROW > IN_COL)? IN_ROW : IN_COL,
  parameter OUT_COL    = (IN_ROW > IN_COL)? IN_ROW : IN_COL,
  parameter DATA_WIDTH = 8
) (
  input  logic [1:0] rotation_angle,
  input  logic [IN_ROW*IN_COL*DATA_WIDTH-1:0] image_in,
  output logic [OUT_ROW*OUT_COL*DATA_WIDTH-1:0] image_out
);

  logic [OUT_ROW*OUT_COL*DATA_WIDTH-1:0] padded_image;
  logic [OUT_ROW*OUT_COL*DATA_WIDTH-1:0] transposed_image;

  generate
    for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin: pad_row_block
      for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin: pad_col_block
        assign padded_image[pad_row*OUT_COL + pad_col] =
          (pad_row < IN_ROW && pad_col < IN_COL)? image_in[(pad_row*IN_COL + pad_col)] :
          0;
      end
    end
  endgenerate

  generate
    for (int trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (int trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        assign transposed_image[trans_row*OUT_COL + trans_col] =
          padded_image[(trans_col*OUT_ROW + trans_row)];
      end
    end
  endgenerate

  always_comb casez(rotation_angle)
    2'b00: begin
      for (int out_row = 0; out_row < OUT_ROW; out_row++) begin: out_row_block
        for (int out_col = 0; out_col < OUT_COL; out_col++) begin: out_col_block
          int in_col = ((OUT_ROW - 1) - out_row)*IN_ROW + out_col;
          int in_row = out_row;
          image_out[(out_row*OUT_COL + out_col)] =
            transposed_image[(in_row*IN_COL + in_col)];
        end
      end
    end

    2'b01: begin
      for (int out_row = 0; out_row < OUT_ROW; out_row++) begin: out_row_block
        for (int out_col = 0; out_col < OUT_COL; out_col++) begin: out_col_block
          int in_col = out_col;
          int in_row = ((OUT_COL - 1) - out_col)*IN_COL + out_row;
          image_out[(out_row*OUT_COL + out_col)] =
            transposed_image[(in_row*IN_COL + in_col)];
        end
      end
    end

    2'b10: begin
      for (int out_row = 0; out_row < OUT_ROW; out_row++) begin: out_row_block
        for (int out_col = 0; out_col < OUT_COL; out_col++) begin: out_col_block
          int in_col = out_col;
          int in_row = out_row;
          image_out[(out_row*OUT_COL + out_col)] =
            transposed_image[(in_row*IN_COL + in_col)];
        end
      end
    end

    2'b11: begin
      for (int out_row = 0; out_row < OUT_ROW; out_row++) begin: out_row_block
        for (int out_col = 0; out_col < OUT_COL; out_col++) begin: out_col_block
          image_out[(out_row*OUT_COL + out_col)] =
            transposed_image[(out_row*OUT_COL + out_col)];
        end
      end
    end
  endcase

endmodule