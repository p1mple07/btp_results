module intra_block #(
    parameter ROW_COL_WIDTH = 16,
    parameter DATA_WIDTH = ROW_COL_WIDTH*ROW_COL_WIDTH
)(
    input logic [DATA_WIDTH-1:0] in_data,  // Input: 256 bits
    output logic [DATA_WIDTH-1:0] out_data // Output: 256 bits rearranged
);

    // Temporary storage for intermediate calculations
    logic [3:0] r_prime [0:255]; // Row index for each bit
    logic [3:0] c_prime [0:255]; // Column index for each bit

    logic [ROW_COL_WIDTH-1:0] prev_out_data [ROW_COL_WIDTH-1:0];

    assign r_prime = {r_prime[255:252], r_prime[247:244]}; // Optimized bitwise operations
    assign c_prime = {c_prime[255:252], c_prime[247:244]};

    assign out_data = in_data[prev_out_data];

endmodule