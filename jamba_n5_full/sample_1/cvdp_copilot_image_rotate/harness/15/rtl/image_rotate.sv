
always_ff @(posedge clk)
  if (srst) begin
    padded_image <= '0;
  end else begin
    for (int pad_row = 0; pad_row < OUT_ROW; pad_row++) begin
      for (int pad_col = 0; pad_col < OUT_COL; pad_col++) begin
        if ((pad_row < IN_ROW) && (pad_col < IN_COL)) begin
          // Copy input data into padded_image
          padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] <= image_in[(pad_row * IN_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH];
        end else begin
          // Fill remaining positions with zeros
          padded_image[(pad_row * OUT_COL + pad_col) * DATA_WIDTH +: DATA_WIDTH] <= '0;
        end
      end
    end
  end
