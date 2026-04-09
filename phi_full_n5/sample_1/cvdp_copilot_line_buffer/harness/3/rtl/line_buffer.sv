// ----------------------------------------
// - Input control
// ----------------------------------------
generate
    for (genvar col = 0; col < NS_COLUMN; col++) begin : unpack_row_image
        assign row_image[NS_COLUMN-col-1] = i_row_image[(col+1)*NBW_DATA-1-:NBW_DATA];
    end
endgenerate

always_ff @(posedge clk or negedge rst_async_n) begin : ctrl_regs
    if(~rst_async_n) begin
        image_window_ff <= 0;
        for (int row = 0; row < NS_ROW; row++) begin
            for (int col = 0; col < NS_COLUMN; col++) begin
                image_buffer_ff[row][col] <= 0;
            end
        end
    end else begin
        if(i_valid) begin
            // Adjusted to use the correct calculation for i_image_row_start and i_image_col_start
            int row_idx = row_image[col] >> NBW_ROW - 1;
            int col_idx = col_image >> NBW_COL - 1;
            image_buffer_ff[row][col] <= row_image[col] & ((1 << NBW_DATA) - 1) << (row * NS_COLUMN + col);

            for (int prev_row = 0; prev_row < row; prev_row++) begin
                image_buffer_ff[prev_row][col] <= image_buffer_ff[row][col];
            end
        end

        if(i_update_window) begin
            image_window_ff <= o_image_window;
        end
    end
end

// ----------------------------------------
// - Output packing
// ----------------------------------------
generate
    for(genvar row = 0; row < NS_R_OUT; row++) begin : out_row
        for(genvar col = 0; col < NS_C_OUT; col++) begin : out_col
            always_comb begin
                if(i_update_window) begin
                    // Adjusted to use the correct calculation for window indexing
                    int window_idx = (row * NS_C_OUT + col) * NBW_DATA;
                    o_image_window[window_idx - 1 : window_idx + NBW_DATA - 1] = window[row][col];
                end else begin
                    o_image_window[window_idx - 1 : window_idx + NBW_DATA - 1] = image_window_ff[window_idx - 1 : window_idx + NBW_DATA - 1];
                end
            end
        end
    end
endgenerate
