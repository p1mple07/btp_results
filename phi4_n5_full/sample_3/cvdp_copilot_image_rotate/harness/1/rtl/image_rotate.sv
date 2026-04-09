module image_rotate #(
  parameter IN_ROW     = 4,                                  // Number of rows in input matrix
  parameter IN_COL     = 4,                                  // Number of columns in input matrix
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic [1:0] rotation_angle,                         // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [ (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,     // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out    // Flattened output image
);

  // Internal signals
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;    // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // -------------------------------------------------------------------
  // Padding Logic:
  // Create a square padded_image from the input image.
  // Copy elements from image_in into the bottom-right portion of padded_image.
  // Top rows and left columns are filled with zeros.
  // -------------------------------------------------------------------
  generate
    for (pad_row = 0; pad_row < OUT_ROW; pad_row = pad_row + 1) begin : pad_row_block
      for (pad_col = 0; pad_col < OUT_COL; pad_col = pad_col + 1) begin : pad_col_block
        if (pad_row < (OUT_ROW - IN_ROW) || pad_col < (OUT_COL - IN_COL))
          // Assign zero to this slice
          padded_image[pad_row*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH] = '0;
        else
          // Copy corresponding element from image_in
          padded_image[pad_row*OUT_COL*DATA_WIDTH + pad_col*DATA_WIDTH +: DATA_WIDTH] =
            image_in[(pad_row - (OUT_ROW - IN_ROW))*IN_COL*DATA_WIDTH + (pad_col - (OUT_COL - IN_COL))*DATA_WIDTH +: DATA_WIDTH];
      end
    end
  endgenerate

  // -------------------------------------------------------------------
  // Transpose Logic:
  // Generate the transposed_image by swapping rows and columns of padded_image.
  // -------------------------------------------------------------------
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row = trans_row + 1) begin : trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col = trans_col + 1) begin : trans_col_block
        transposed_image[trans_row*OUT_COL*DATA_WIDTH + trans_col*DATA_WIDTH +: DATA_WIDTH] =
          padded_image[trans_col*OUT_ROW*DATA_WIDTH + trans_row*DATA_WIDTH +: DATA_WIDTH];
      end
    end
  endgenerate

  // -------------------------------------------------------------------
  // Output Logic:
  // Based on rotation_angle, compute the rotated output.
  // 90° (00): Use transposed_image and reverse rows.
  // 180° (01): Reverse rows and columns of padded_image.
  // 270° (10): Use transposed_image and reverse columns.
  // No Rotation (11): Pass through padded_image.
  // -------------------------------------------------------------------
  always_comb begin
    unique case (rotation_angle)
      2'b00: begin // 90° clockwise: reverse rows of transposed_image
        for (rot_row = 0; rot_row < OUT_ROW; rot_row = rot_row + 1) begin
          for (rot_col = 0; rot_col < OUT_COL; rot_col = rot_col + 1) begin
            image_out[rot_row*OUT_COL*DATA_WIDTH + rot_col*DATA_WIDTH +: DATA_WIDTH] =
              transposed_image[(OUT_ROW - 1 - rot_row)*OUT_COL*DATA_WIDTH + rot_col*DATA_WIDTH +: DATA_WIDTH];
          end
        end
      end
      2'b01: begin // 180° clockwise: reverse rows and columns of padded_image
        for (rot_row = 0; rot_row < OUT_ROW; rot_row = rot_row + 1) begin
          for (rot_col = 0; rot_col < OUT_COL; rot_col = rot_col + 1) begin
            image_out[rot_row*OUT_COL*DATA_WIDTH + rot_col*DATA_WIDTH +: DATA_WIDTH] =
              padded_image[(OUT_ROW - 1 - rot_row)*OUT_COL*DATA_WIDTH + (OUT_COL - 1 - rot_col)*DATA_WIDTH +: DATA_WIDTH];
          end
        end
      end
      2'b10: begin // 270° clockwise: reverse columns of transposed_image
        for (rot_row = 0; rot_row < OUT_ROW; rot_row = rot_row + 1) begin
          for (rot_col = 0; rot_col < OUT_COL; rot_col = rot_col + 1) begin
            image_out[rot_row*OUT_COL*DATA_WIDTH + rot_col*DATA_WIDTH +: DATA_WIDTH] =
              transposed_image[rot_row*OUT_COL*DATA_WIDTH + (OUT_COL - 1 - rot_col)*DATA_WIDTH +: DATA_WIDTH];
          end
        end
      end
      2'b11: begin // No Rotation: pass through padded_image
        image_out = padded_image;
      end
      default: image_out = '0;
    endcase
  end

endmodule