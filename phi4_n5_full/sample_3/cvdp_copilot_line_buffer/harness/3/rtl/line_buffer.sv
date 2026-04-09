
module line_buffer #(
    parameter NBW_DATA  = 'd8,  // Bit width of grayscale input/output data
    parameter NS_ROW    = 'd10, // Number of rows
    parameter NS_COLUMN = 'd8,  // Number of columns
    parameter NBW_ROW   = 'd4,  // log2(NS_ROW). Bit width of i_image_row_start
    parameter NBW_COL   = 'd3,  // log2(NS_COLUMN). Bit width of i_image_col_start
    parameter NBW_MODE  = 'd3,  // Bit width of mode input
    parameter NS_R_OUT  = 'd4,  // Number of rows of the output window
    parameter NS_C_OUT  = 'd3,  // Number of columns of the output window
    parameter CONSTANT  = 'd255 // Constant value to use in PAD_CONSTANT mode
) (
    input  logic                                  clk,
    input  logic                                  rst_async_n,
    input  logic [NBW_MODE-1:0]                   i_mode,
    input  logic                                  i_valid,
    input  logic                                  i_update_window,
    input  logic [NBW_DATA*NS_COLUMN-1:0]         i_row_image,
    input  logic [NBW_ROW-1:0]                    i_image_row_start,
    input  logic [NBW_COL-1:0]                    i_image_col_start,
    output logic [NBW_DATA*NS_R_OUT*NS_C_OUT-1:0] o_image_window
);
