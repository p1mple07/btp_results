module
module line_buffer #(
    parameter NBW_DATA  = 'd8,  // Bit width of grayscale input data
    parameter NS_ROW    = 'd10, // Number of rows
    parameter NS_COLUMN = 'd8,  // Number of columns
    parameter NBW_MODE  = 'd3,  // Bit width of mode selection
    parameter NS_R_OUT  = 'd4,  // Number of rows in output window
    parameter NS_C_OUT  = 'd3,  // Number of columns in output window
    parameter CONSTANT  = 'd255 // Constant value for padding mode
) (
    input  logic      clk,
    input  logic      rst_async_n,
    input  logic [NBW_MODE-1:0] i_mode,
    input  logic [NBW_DATA*NS_COLUMN-1:0] i_row_image,
    input  logic [NBW_ROW-1:0] i_image_row_start,
    input  logic [NBW_COL-1:0] i_image_col_start,
    input  logic [NBW_DATA*NS_R_OUT*NS_C_OUT-1:0] i_update_window,
    output logic [NBW_DATA*NS_R_OUT*NS_C_OUT-1:0] o_image_window;

    // Internal registers
    logic [NBW_DATA-1:0] image_buffer_ff [NS_ROW][NS_COLUMN];
    logic [NBW_DATA-1:0] row_image [NS_COLUMN];
    logic [NBW_DATA-1:0] window [NS_R_OUT][NS_C_OUT];
    logic [NBW_DATA-1:0] image_window_ff [NS_R_OUT][NS_C_OUT];

    // Control signals
    logic @rst Negative edge rst_async_n;

    // Signal assignments
    always_comb begin
        // Window assignment
        case(i_mode)
            3'd0: begin // NO Border PROCESS
                for (int row = 0; row < NS_R_OUT; row++) begin
                    for (int col = 0; col < NS_C_OUT; col++) begin
                        if(i_image_row_start + col >= NS_COLUMN) begin
                            window[row][col] = 0;
                        end else if (i_image_col_start + row >= NS_COLUMN) begin
                            window[row][col] = 0;
                        end else begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                        end
                    end
                end
            3'd1: begin // PAD_CONSTANT
                for (int row = 0; row < NS_R_OUT; row++) begin
                    for (int col = 0; col < NS_C_OUT; col++) begin
                        if(i_image_row_start + col >= NS_COLUMN) begin
                            window[row][col] = CONSTANT;
                        end else if (i_image_col_start + row >= NS_COLUMN) begin
                            window[row][col] = CONSTANT;
                        end else begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                        end
                    end
                end
            3'd2: begin // EXTEND_NEAR
                for (int row = 0; row < NS_R_OUT; row++) begin
                    for (int col = 0; col < NS_C_OUT; col++) begin
                        if(i_image_row_start + col >= NS_COLUMN) begin
                            window[row][col] = image_buffer_ff[NS_ROW-1][i_image_col_start + row];
                        end else if (i_image_col_start + row >= NS_COLUMN) begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][NS_COLUMN-1];
                        end else begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                        end
                    end
                end
            3'd3: begin // MIRROR_BOUND
                for (int row = 0; row < NS_R_OUT; row++) begin
                    for (int col = 0; col < NS_C_OUT; col++) begin
                        if(i_image_row_start + col >= NS_COLUMN) begin
                            window[row][col] = image_buffer_ff[NS_ROW-1][i_image_col_start + row];
                        end else if (i_image_col_start + row >= NS_COLUMN) begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][NS_COLUMN-1];
                        end else begin
                            window[row][col] = image_buffer_ff[i_image_row_start + col][i_image_col_start + row];
                        end
                    end
                end
            default: begin
                for (int row = 0; row < NS_R_OUT; row++) begin
                    for (int col = 0; col < NS_C_OUT; col++) begin
                        window[row][col] = 0;
                    end
                end
            end
        endcase
    endgenerate

    // Output generation
    generate
        for (genvar row = 0; row < NS_R_OUT; row++) begin : window_assignment
            for (genvar col = 0; col < NS_C_OUT; col++) begin : out_row
                always_comb begin
                    if(i_update_window) begin
                        o_image_window[(row * NS_C_OUT + col) * NBW_DATA] = window[row][col];
                    end else begin
                        o_image_window[(row * NS_C_OUT + col) * NBW_DATA] = image_window_ff[row][col];
                    end
                end
            end
        end
    endgenerate
endmodule