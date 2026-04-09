module Bit_Difference_Counter
#(
    parameter [2:0] BIT_WIDTH = 4, // Width of input vectors
    parameter [2:0] COUNT_WIDTH = 3 // Width to represent count
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    // Perform bitwise XOR to find differing bits
    Data_Reduction
    #(
        .REDUCTION_OP (3'b001), // XOR operation
        .DATA_WIDTH (BIT_WIDTH),
        .DATA_COUNT (BIT_WIDTH)
    )
    data_reductor
    (
        .data_in (input_A ^ input_B),
        .reduced_data_out (bit_difference_count)
    );

    // Count the number of differing bits
    Bitwise_Reduction
    #(
        .REDUCTION_OP (3'b001), // XOR operation
        .BIT_COUNT (COUNT_WIDTH)
    )
    bit_count
    (
        .input_bits (bit_difference_count),
        .reduced_bit (bit_difference_count)
    );
endmodule