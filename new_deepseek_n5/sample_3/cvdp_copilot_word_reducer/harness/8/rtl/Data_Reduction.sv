module Data_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
    parameter [2:0] BIT_COUNT    = 3'b000, // Default count: 0
    parameter [2:0] DATA_WIDTH  = 4,      // Width of each data element
)
(
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] reduced_data_out
);

    generate
        genvar bit_index;

        // Iterate over each bit position within a single data word
        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [DATA_COUNT-1:0] extracted_bits;

            // Extract the bits at `bit_index` from each data word
            for (data_index = 0; data_index < DATA_COUNT; data_index = data_index + 1) begin : bit_extraction
                assign extracted_bits[data_index] = data_in[(data_index * DATA_WIDTH) + bit_index];
            end

            // Perform reduction on the extracted bits
            Bitwise_Reduction
            #(
                .REDUCTION_OP (REDUCTION_OP),
                .BIT_COUNT (BIT_COUNT),
                .DATA_WIDTH (DATA_WIDTH)
            )
            reducer_instance
            (
                .input  bits  = extracted_bits,
                .reduced_bit (reduced_bit) = 0,
            );
        end
    endgenerate

endmodule

module Bitwise_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
    parameter [2:0] BIT_COUNT    = 3'b000, // Default count: 0
    parameter [2:0] DATA_WIDTH  = 4,      // Width of each data element
)
(
    input  wire [DATA_WIDTH-1:0] input_bits,
    output reg  [DATA_WIDTH-1:0] output_reg[0],
);

    generate
        genvar i;
        genvar j;
        genvar k;
        reg temp_result; // Intermediate result

        // Iterate over each bit position within a single data word
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin : bit_extraction
            // Extract bit at `i` from each data word
            wire [DATA_COUNT-1:0] extracted_bits;

            for (j = 0; j < DATA_COUNT; j = j + 1) begin : bit_processing
                assign extracted_bits[j] = input_bits[(j * DATA_WIDTH) + i];
            end

            // Perform reduction on the extracted bits
            case (REDUCTION_OP)
                AND_OP, NAND_OP  : temp_result = temp_result & extracted_bits[j];
                OR_OP,  NOR_OP   : temp_result = temp_result | extracted_bits[j];
                XOR_OP  : temp_result = temp_result ^ extracted_bits[j];
                // Add your implementation for other operations
                default : temp_result = temp_result & extracted_bits[j];
            endcase

            // Apply final inversion if required
            case (REDUCTION_OP)
                NAND_OP : output_reg[0] = ~temp_result;
                NOR_OP  : output_reg[0] = ~temp_result;
                XNOR_OP : output_reg[0] = ~temp_result;
                default : output_reg[0] = temp_result;
            endcase
        end
    endgenerate

endmodule