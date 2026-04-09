
if (i_image_row_start + col >= NS_ROW) begin
    window[row][col] = image_buffer_ff[2*NS_ROW-1-(i_image_row_start + col)][i_image_col_start + row];
  end else if (i_image_col_start + row >= NS_COLUMN) begin
    window[row][col] = image_buffer_ff[i_image_row_start + col][NS_COLUMN-1-(i_image_col_start + row)];
  end else begin
    window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
  end
