module inter_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter SUB_BLOCKS    = 4,
    parameter DATA_WIDTH    = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [DATA_WIDTH-1:0] in_data, // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

//... (rest of the module implementation)

endmodule