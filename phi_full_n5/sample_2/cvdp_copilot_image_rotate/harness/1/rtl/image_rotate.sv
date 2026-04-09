module image_rotate #(
  parameter IN_ROW     = 4,
  parameter IN_COL     = 4,
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
  for (pad_row = 0; pad_row < OUT_ROW; pad_row++) begin : pad_row_loop
    for (pad_col = 0; pad_col < OUT_COL; pad_col++) begin : pad_col_loop
      case (pad_row)
        0: padded_image[(pad_row*OUT_COL+pad_col)*DATA_WIDTH+:DATA_WIDTH] = 0;
        default: padded_image[(pad_row*OUT_COL+pad_col)*DATA_WIDTH+:DATA_WIDTH] = image_in[(IN_ROW*IN_COL+(pad_row-1)*IN_COL+pad_col-1)*DATA_WIDTH+:DATA_WIDTH];
      endcase
    end
  end

  // Transposed image logic
  for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin : trans_row_block
    for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin : trans_col_block
      case (trans_col)
        0: transposed_image[(trans_row)*DATA_WIDTH+:DATA_WIDTH] = 0;
        default: transposed_image[(trans_row)*DATA_WIDTH+:DATA_WIDTH] = padded_image[(trans_col)*OUT_ROW+:DATA_WIDTH];
      endcase
    end
  end

  // Output logic based on rotation_angle
  always_comb begin
    case (rotation_angle)
      0: image_out = transposed_image; // 90° rotation
      1: {
        {image_out[OUT_ROW*OUT_COL-1:OUT_ROW*OUT_COL*DATA_WIDTH-1]} = {image_in[IN_ROW*IN_COL-1:IN_ROW*IN_COL*DATA_WIDTH-1]};
        {image_out[IN_ROW*OUT_COL:IN_ROW*OUT_COL*DATA_WIDTH-1]} = {image_in[IN_ROW*IN_COL+:IN_ROW*IN_COL*DATA_WIDTH]};
        {image_out[IN_ROW*OUT_COL*DATA_WIDTH:IN_ROW*OUT_COL*DATA_WIDTH-1]} = {image_in[IN_ROW+:IN_ROW*DATA_WIDTH]};
        {image_out[IN_ROW*OUT_COL*DATA_WIDTH:IN_ROW*OUT_COL*DATA_WIDTH-1]} = {image_in[IN_COL-1:IN_COL*DATA_WIDTH-1]};
      }
      0b1: image_out = padded_image; // 180° rotation
      0b10: {
        {image_out[OUT_ROW-1:OUT_ROW*OUT_COL-1]} = {image_in[(IN_ROW-1)*IN_COL-1:IN_ROW*IN_COL-1]};
        {image_out[OUT_ROW*OUT_COL-1:OUT_ROW*OUT_COL*DATA_WIDTH-1]} = {image_in[(IN_ROW-1)*IN_COL+:IN_ROW*IN_COL*DATA_WIDTH]};
        {image_out[(OUT_ROW-1)*OUT_COL*DATA_WIDTH:(OUT_ROW-1)*OUT_COL*DATA_WIDTH-1]} = {image_in[(IN_ROW-1)+:IN_ROW*DATA_WIDTH]};
        {image_out[(OUT_ROW-1)*OUT_COL*DATA_WIDTH:(OUT_ROW-1)*OUT_COL*DATA_WIDTH-1]} = {image_in[(IN_COL-1)-1:(IN_COL-1)*DATA_WIDTH]};
      }
      0b11: image_out = padded_image; // No rotation
    endcase
  end

endmodule
