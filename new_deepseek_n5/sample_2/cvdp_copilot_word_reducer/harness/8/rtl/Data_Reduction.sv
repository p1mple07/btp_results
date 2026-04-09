module Bit_Difference_Counter(
    parameter BIT_WIDTH,
    parameter COUNT_WIDTH,
    input wire [BIT_WIDTH-1:0] input_A,
    input wire [BIT_WIDTH-1:0] input_B
)
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    // Compute XOR of input_A and input_B to find differing bits
    Data_Reduction
    #(
        parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
        parameter DATA_WIDTH         = 1,      // Width of each data element
        parameter DATA_COUNT         = 2,      // Number of data elements
        localparam TOTAL_INPUT_WIDTH = DATA_WIDTH * DATA_COUNT
    )
    reducer_instance
    (
        .data_in(input_A ^ input_B), // XOR operation using Data_Reduction
        .reduced_data_out(bit_difference_count[0]) // Store XOR result in first bit of output
    );

    // Count the number of differing bits using Bitwise_Reduction
    Bitwise_Reduction
    #(
        parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
        parameter BIT_COUNT          = BIT_WIDTH
    )
    reducer_instance
    (
        .input_bits(bit_difference_count[1:0]), // Use remaining bits for counting
        .reduced_bit(bit_difference_count[BIT_WIDTH:0]) // Final count stored in output
    );
endmodule