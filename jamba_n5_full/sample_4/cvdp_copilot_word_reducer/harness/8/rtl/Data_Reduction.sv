module Data_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
    parameter DATA_WIDTH         = 4,      // Width of each data element
    parameter DATA_COUNT         = 4,      // Number of data elements
    localparam TOTAL_INPUT_WIDTH = DATA_WIDTH * DATA_COUNT
)
(
    input  wire [TOTAL_INPUT_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0]        reduced_data_out
);

    generate
        genvar bit_index;

        // Iterate over each bit position within a single data word
        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [DATA_COUNT-1:0] extracted_bits;

            // Extract bit at `bit_index` from each data word
            genvar data_index;
            for (data_index = 0; data_index < DATA_COUNT; data_index = data_index + 1) begin : bit_extraction
                assign extracted_bits[data_index] = data_in[(data_index * DATA_WIDTH) + bit_index];
            end

            // Perform reduction on the extracted bits
            Bitwise_Reduction
            #(
                .REDUCTION_OP (REDUCTION_OP),
                .BIT_COUNT    (DATA_COUNT)
            )
            reducer_instance
            (
                .input_bits  (extracted_bits),
                .reduced_bit (reduced_data_out[bit_index])
            );
        end
    endgenerate

endmodule

module Bit_Difference_Counter#(
    parameter BIT_WIDTH = 4
) (
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg bit_difference_count
);

    wire xor_result = input_A ^ input_B;

    localvar int count = 0;
    for (int i = 0; i < BIT_WIDTH; i = i + 1) begin
        if (xor_result[i] == 1) begin
            count++;
        end
    end

    assign bit_difference_count = count;

endmodule
