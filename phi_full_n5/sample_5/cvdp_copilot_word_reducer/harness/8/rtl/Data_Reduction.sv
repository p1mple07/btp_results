module Bit_Difference_Counter
#(
    parameter [2:0] BIT_WIDTH = 3, // Default width of input vectors
    parameter integer COUNT_WIDTH = BIT_WIDTH  // Calculate count width
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    // Perform bitwise XOR to identify differing bits
    wire [BIT_WIDTH-1:0] xor_result;
    xor_result = input_A ^ input_B;

    // Count the number of set bits (1s) in the XOR result
    wire [COUNT_WIDTH-1:0] count_bits;
    Bitwise_Reduction #(
        .REDUCTION_OP (3'b100) // NOR operation to count set bits
    )
    reducer_instance
    (
        .input_bits  (xor_result),
        .reduced_bit (count_bits)
    );

    assign bit_difference_count = count_bits;

endmodule
