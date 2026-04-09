// Corrected RTL code for line_buffer module
module line_buffer #(
    parameter NBW_DATA  = 'd8,  // Bit width of grayscale input data
    parameter NS_ROW    = 'd10, // Number of rows
    parameter NS_COLUMN = 'd8,  // Number of columns
    parameter NBW_ROW   = 'd4,  // Log2(NS_ROW). Bit width of i_image_row_start
    parameter NBW_COL   = 'd3,  // Log2(NS_COLUMN). Bit width of i_image_col_start
    parameter NBW_MODE  = 'd3,  // Bit width of mode selection signal
    parameter NS_R_OUT  = 'd4,  // Number of rows in output window
    parameter NS_C_OUT  = 'd3,  // Number of columns in output window
    parameter NBW_MODE  = 'd3,  // Bit width of mode selection signal
) (
    // Internal signals creation
    logic [NBW_DATA*NS_R_OUT*NS_C_OUT-1:0] o_image_window
);

// Initialize a window of pixel data from an image row buffer
always_comb begin : top
    image_buffer_ff [NS_ROW][NS_COLUMN] = 0;
    row_image [NS_COLUMN] = 0;
    column_image [NS_ROW] = 0;
    window [NS_R_OUT][NS_C_OUT] = 0;
    logic [NBW_DATA-1:0] image_buffer_ff [NBW_MODE-1:(i_MODE-1) ? 0 : 255] = 0;
    logic [NBW_DATA-1:0] row_image [NBW_DATA-1:0] = 0;
    logic [NBW_DATA-1:0] column_image [NBW_DATA-1:0] = 0;
    logic [NBW_DATA-1:0] window [NBW_DATA-1:0] = 0;
    image_window_ff [NBW_DATA-1:0] = 0;
    row_image [NS_COLUMN] = 0;
    column_image [NS_ROW] = 0;
    image_buffer [NS_ROW][NS_COLUMN] = 0;
    window [NS_R_OUT][NS_C_OUT] = 0;
end

// Output generation
generate
    for (genvar col = 0; col < NS_C_OUT; col++) begin : out_col
        for (genvar row = 0; row < NS_R_OUT; row++) begin : out_row
            always_comb begin
                if(i_mode == 3) begin // MAX_EXTEND
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_ROW) begin
                                window[row][col] = 0;
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else begin
                                window[row][col] = image_buffer[(i_image_row_start + col) + (i_image_col_start + row) * NS_COLUMN][i_image_col_start + row];
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // PAD_CONSTANT
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else begin
                                window[row][col] = constant;
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // MIRROR
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = image_buffer[(NS_COLUMN - 1 - (i_image_row_start + col))][i_image_col_start + row];
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = image_buffer[i_image_row_start + col][NS_COLUMN - 1 - (i_image_col_start + row)];
                            end else begin
                                window[row][col] = image_buffer[i_image_row_start + col][i_image_col_start + row];
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // WARP
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = image_buffer[2*NS_COLUMN-1-(i_image_row_start + col)][i_image_col_start + row];
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = image_buffer[i_image_row_start + col][2*NS_COLUMN-1-(i_image_col_start + row)];
                            end else begin
                                window[row][col] = image_buffer[i_image_row_start + col][i_image_col_start + row];
                            end
                        end
                    end
                end
                for (int r = 0; r < NS_R_OUT; r++) begin : out_row
                    for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                        always_comb begin
                            if(i_update_window) begin
                                o_image_window[(row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA : (row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA + NBW_DATA -1 : NBW_DATA] = window[row][col];
                            end else begin
                                o_image_window[(row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA : (row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA + NBW_DATA -1 : NBW_DATA] = image_window_ff[(row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA : (row * (NS_C_OUT * NBW_DATA) + col) * NBW_DATA + NBW_DATA -1 : NBW_DATA];
                            end
                        end
                    end
                end
            end
        end
    end
endgenerate

// Corrected address calculation
generate
    for (genvar col = 0; col < NS_C_OUT; col++) begin : out_col
        for (genvar row = 0; row < NS_R_OUT; row++) begin : out_row
            always_comb begin
                if(i_mode == 3) begin // MAX_EXTEND
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_ROW) begin
                                window[row][col] = 0;
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else begin
                                window[row][col] = image_buffer[(i_image_row_start + col) + (i_image_col_start + row) * NS_COLUMN][i_image_col_start + row];
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // PAD_CONSTANT
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = 0;
                            end else begin
                                window[row][col] = constant;
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // MIRROR
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = image_buffer[(NS_COLUMN - 1 - (i_image_row_start + col))][i_image_col_start + row];
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = image_buffer[i_image_row_start + col][NS_COLUMN - 1 - (i_image_col_start + row)];
                            end else begin
                                window[row][col] = image_buffer[i_image_row_start + col][i_image_col_start + row];
                            end
                        end
                    end
                end
                if (i_mode == 3) begin // WARP
                    for (int r = 0; r < NS_R_OUT; r++) begin : out_col
                        for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                            if(i_image_row_start + col >= NS_COLUMN) begin
                                window[row][col] = image_buffer[2*NS_COLUMN-1-(i_image_row_start + col)][i_image_col_start + row];
                            end else if (i_image_col_start + row >= NS_COLUMN) begin
                                window[row][col] = image_buffer[i_image_row_start + col][2*NS_COLUMN-1-(i_image_col_start + row)];
                            end else begin
                                window[row][col] = image_buffer[i_image_row_start + col][i_image_col_start + row];
                            end
                        end
                    end
                end
                for (int r = 0; r < NS_R_OUT; r++) begin : out_row
                    for (int c = 0; c < NS_C_OUT; c++) begin : out_col
                        always_comb begin
                            if(i_update_window) begin
                                o_image_window[row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA : row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA + NBW_DATA -1 : NBW_DATA] = window[row][col];
                            end else begin
                                o_image_window[row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA : row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA + NBW_DATA -1 : NBW_DATA] = image_window_ff[row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA : row * (NS_C_OUT * NBW_DATA) + col * NBW_DATA + NBW_DATA -1 : NBW_DATA];
                            end
                        end
                    end
                end
            end
        end
    end
endgenerate