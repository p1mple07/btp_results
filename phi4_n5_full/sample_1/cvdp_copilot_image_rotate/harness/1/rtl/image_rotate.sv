module image_rotate #(
  parameter IN_ROW     = 4                                  , // Number of rows in input matrix
  parameter IN_COL     = 4                                  , // Number of columns in input matrix
  parameter OUT_ROW    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output rows after padding
  parameter OUT_COL    = (IN_ROW > IN_COL) ? IN_ROW : IN_COL, // Output columns after padding
  parameter DATA_WIDTH = 8                                    // Bit-width of data
) (
  input  logic [1:0] rotation_angle, // Rotation angle (00: 90°, 01: 180°, 10: 270°, 11: No Rotation)
  input  logic [ (IN_ROW*IN_COL*DATA_WIDTH)-1:0] image_in, // Flattened input image
  output logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] image_out // Flattened output image
);

  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] padded_image;   // Padded square image
  logic [(OUT_ROW*OUT_COL*DATA_WIDTH)-1:0] transposed_image; // Transposed square image

  genvar pad_row, pad_col, trans_row, trans_col, rot_row, rot_col;

  // Padding Logic: Create a square padded_image from image_in.
  // For positions where (row, col) is within the input dimensions, copy the data;
  // otherwise, assign zero.
  generate
    for (pad_row = 0; pad_row < OUT_ROW; pad_row = pad_row + 1) begin : pad_row_block
      for (pad_col = 0; pad_col < OUT_COL; pad_col = pad_col + 1) begin : pad_col_block
        if (pad_row < IN_ROW && pad_col < IN_COL) begin
          assign padded_image[((pad_row*OUT_COL+pad_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                  image_in[((pad_row*IN_COL+pad_col)*DATA_WIDTH)+:DATA_WIDTH];
        end else begin
          assign padded_image[((pad_row*OUT_COL+pad_col)*DATA_WIDTH)+:DATA_WIDTH] = {DATA_WIDTH{1'b0}};
        end
      end
    end
  endgenerate

  // Transpose Logic: Generate transposed_image by swapping rows and columns of padded_image.
  generate
    for (trans_row = 0; trans_row < OUT_ROW; trans_row = trans_row + 1) begin : trans_row_block
      for (trans_col = 0; trans_col < OUT_COL; trans_col = trans_col + 1) begin : trans_col_block
        assign transposed_image[((trans_row*OUT_COL+trans_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                padded_image[((trans_col*OUT_COL+trans_row)*DATA_WIDTH)+:DATA_WIDTH];
      end
    end
  endgenerate

  // Output Logic: Compute the rotated output based on the rotation_angle.
  // 90° (00): Use transposed_image and reverse rows.
  // 180° (01): Reverse rows and columns using padded_image.
  // 270° (10): Use transposed_image and reverse columns.
  // No Rotation (11): Pass through padded_image.
  generate
    for (rot_row = 0; rot_row < OUT_ROW; rot_row = rot_row + 1) begin : rot_row_block
      for (rot_col = 0; rot_col < OUT_COL; rot_col = rot_col + 1) begin : rot_col_block
        case (rotation_angle)
          2'b00: begin
            // 90° clockwise: image_out[rot_row][rot_col] = transposed_image[OUT_ROW-1-rot_row][rot_col]
            assign image_out[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                     transposed_image[(( (OUT_ROW - 1 - rot_row) * OUT_COL + rot_col) * DATA_WIDTH)+:DATA_WIDTH];
          end
          2'b01: begin
            // 180° clockwise: image_out[rot_row][rot_col] = padded_image[OUT_ROW-1-rot_row][OUT_COL-1-rot_col]
            assign image_out[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                     padded_image[(( (OUT_ROW - 1 - rot_row) * OUT_COL + (OUT_COL - 1 - rot_col)) * DATA_WIDTH)+:DATA_WIDTH];
          end
          2'b10: begin
            // 270° clockwise: image_out[rot_row][rot_col] = transposed_image[rot_row][OUT_COL-1-rot_col]
            assign image_out[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                     transposed_image[(( (rot_row*OUT_COL + (OUT_COL - 1 - rot_col)) * DATA_WIDTH)+:DATA_WIDTH];
          end
          2'b11: begin
            // No Rotation: image_out = padded_image
            assign image_out[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH] = 
                     padded_image[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH];
          end
          default: begin
            assign image_out[((rot_row*OUT_COL+rot_col)*DATA_WIDTH)+:DATA_WIDTH] = {DATA_WIDTH{1'b0}};
          end
        endcase
      end
    end
  endgenerate

endmodule