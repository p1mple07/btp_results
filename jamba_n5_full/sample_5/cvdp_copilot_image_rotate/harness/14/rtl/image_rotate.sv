
case (rotation_angle)
  // 90° Clockwise: Transpose + Reverse Rows
  2'b00: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= transposed_image_reg[(rot_row * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

  // 180° Clockwise: Reverse Rows and Columns
  2'b01: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = padded_image_reg3[((OUT_ROW-1-rot_row) * OUT_COL + (OUT_COL-1-rot_col)) * DATA_WIDTH +: DATA_WIDTH];

  // 270° Clockwise: Transpose + Reverse Columns
  2'b10: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] = transposed_image_reg[((OUT_ROW-1-rot_row) * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];

  // No Rotation (Pass-through)
  2'b11: rotated_image[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH] <= padded_image_reg3[(rot_row * OUT_COL + rot_col) * DATA_WIDTH +: DATA_WIDTH];
