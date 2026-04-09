module image_rotate #(
  parameter IN_ROW     = 4                                  , // Number of rows in input matrix
  parameter IN_COL     = 4                                  , // Number of columns in input matrix
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic [1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [(IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in,      // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out     // Flattened output image
);

  // Intermediate signals
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;    // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // -----------------------------------------------------------------
  // Padded image generation: Create a square padded_image of size OUT_ROW x OUT_COL.
  // The bottom-right IN_ROW x IN_COL portion is filled with image_in, while the rest are zeros.
  // -----------------------------------------------------------------
  always_comb begin
    for (int r = 0; r < OUT_ROW; r++) begin
      for (int c = 0; c < OUT_COL; c++) begin
        if (r < (OUT_ROW - IN_ROW) || c < (OUT_COL - IN_COL)) begin
          // Top rows or left columns: assign zero
          padded_image[((r*OUT_COL + c)*DATA_WIDTH) +: DATA_WIDTH] = '0;
        end else begin
          // Map padded image indices to input image indices
          int in_row = r - (OUT_ROW - IN_ROW);
          int in_col = c - (OUT_COL - IN_COL);
          int pixel_index = in_row * IN_COL + in_col;
          padded_image[((r*OUT_COL + c)*DATA_WIDTH) +: DATA_WIDTH] = image_in[(pixel_index*DATA_WIDTH) +: DATA_WIDTH];
        end
      end
    end
  end

  // -----------------------------------------------------------------
  // Transpose logic: Generate transposed_image by swapping rows and columns of padded_image.
  // For a matrix element at (i,j) in padded_image, the corresponding element in transposed_image is at (j,i).
  // -----------------------------------------------------------------
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row++) begin: trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col++) begin: trans_col_block
        assign transposed_image[((trans_col*OUT_ROW + trans_row)*DATA_WIDTH) +: DATA_WIDTH] =
          padded_image[((trans_row*OUT_COL + trans_col)*DATA_WIDTH) +: DATA_WIDTH];
      end
    end
  endgenerate

  // -----------------------------------------------------------------
  // Output logic: Based on the rotation_angle, compute the rotated output image.
  // The image_out is constructed pixel-by-pixel using the following rules:
  //   90° (00): Use transposed_image and reverse the row order.
  //   180° (01): Reverse both rows and columns of padded_image.
  //   270° (10): Use transposed_image and reverse the column order.
  //   No Rotation (11): Pass through padded_image.
  // -----------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < OUT_ROW; i++) begin
      for (int j = 0; j < OUT_COL; j++) begin
        case (rotation_angle)
          2'b00: begin
            // 90° clockwise: image_out[i][j] = transposed_image[OUT_ROW-1-i][j]
            image_out[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH] =
              transposed_image[(( (OUT_ROW-1-i)*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH];
          end
          2'b01: begin
            // 180° clockwise: image_out[i][j] = padded_image[ (OUT_ROW-1-i)*OUT_COL + (OUT_COL-1-j) ]
            image_out[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH] =
              padded_image[(( (OUT_ROW-1-i)*OUT_COL + (OUT_COL-1-j))*DATA_WIDTH) +: DATA_WIDTH];
          end
          2'b10: begin
            // 270° clockwise: image_out[i][j] = transposed_image[i][OUT_COL-1-j]
            image_out[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH] =
              transposed_image[(( i*OUT_COL + (OUT_COL-1-j))*DATA_WIDTH) +: DATA_WIDTH];
          end
          2'b11: begin
            // No Rotation: image_out[i][j] = padded_image[i][j]
            image_out[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH] =
              padded_image[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH];
          end
          default: begin
            // Default case (should not occur)
            image_out[((i*OUT_COL + j)*DATA_WIDTH) +: DATA_WIDTH] = '0;
          end
        endcase
      end
    end
  end

endmodule