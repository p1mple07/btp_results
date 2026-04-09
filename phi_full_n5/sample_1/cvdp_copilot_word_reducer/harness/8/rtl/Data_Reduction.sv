module Bit_Difference_Counter
#(
    parameter [BIT_WIDTH-1:0] BIT_WIDTH = 4, // Width of input vectors
    parameter logic [COUNT_WIDTH-1:0] COUNT_WIDTH // Width required to represent maximum possible Hamming distance
)
(
    input  logic [BIT_WIDTH-1:0] input_A,
    input  logic [BIT_WIDTH-1:0] input_B,
    output logic [COUNT_WIDTH-1:0] bit_difference_count
);

    // Calculate the maximum number of differing bits
    logic [BIT_WIDTH-1:0] xor_result;
    assign xor_result = input_A ^ input_B;
    assign COUNT_WIDTH = BIT_WIDTH; // Since the maximum possible Hamming distance is equal to BIT_WIDTH

    // Use Data_Reduction to count the number of differing bits
    generate
        genvar bit_index;
        for (bit_index = 0; bit_index < BIT_WIDTH; bit_index = bit_index + 1) begin : bit_index_loop
            logic [COUNT_WIDTH-1:0] temp_count;
            assign temp_count = Data_Reduction(
                .REDUCTION_OP(3'b001), // Use XOR operation for differing bits
                .BIT_COUNT(COUNT_WIDTH)
            )(
                .input_bits(xor_result[bit_index]),
                .reduced_bit(temp_count)
            );
            bit_difference_count = bit_difference_count + temp_count;
        end
    endgenerate

endmodule
