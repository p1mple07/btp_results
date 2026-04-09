module Bitwise_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b000, // Default operation: AND
    parameter BIT_COUNT          = 4       // Number of bits to reduce
)
(
    input  wire [BIT_COUNT-1:0] input_bits,
    output reg                  reduced_bit
);

    // Reduction Operation Codes
    localparam [2:0] AND_OP  = 3'b000;
    localparam [2:0] OR_OP   = 3'b001;
    localparam [2:0] XOR_OP  = 3'b010;
    localparam [2:0] NAND_OP = 3'b011;
    localparam [2:0] NOR_OP  = 3'b100;
    localparam [2:0] XNOR_OP = 3'b101;

    int i;
    reg temp_result; // Intermediate result

    always @(*) begin
        // Initialize result with the first bit
        temp_result = input_bits[0];

        // Reduce bits using the selected operation
        for (i = 1; i < BIT_COUNT; i = i + 1) begin
            case (REDUCTION_OP)
                AND_OP, NAND_OP  : temp_result = temp_result & input_bits[i];
                OR_OP,  NOR_OP   : temp_result = temp_result | input_bits[i];
                XOR_OP, XNOR_OP  : temp_result = temp_result ^ input_bits[i];
                default          : temp_result = temp_result & input_bits[i];
            endcase
        end
    end
endmodule

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

            // Extract the corresponding bits for the current bit position
            for (int j = 0; j < DATA_COUNT; j = j + 1) begin
                extracted_bits[j] = data_in[(j * DATA_WIDTH) + bit_index];
            end

            // Use the Bitwise_Reduction module to perform the reduction operation
            wire reduced_bit;
            Bitwise_Reduction #(DATA_WIDTH, REDUCTION_OP) bitwise_reduction_module(extracted_bits, reduced_bit);

            // Combine the outputs of all Bitwise_Reduction modules to form the final reduced output bit
            case (bit_index)
                0: reduced_data_out[0] = reduced_bit;
                1: reduced_data_out[1] = reduced_bit;
                2: reduced_data_out[2] = reduced_bit;
                3: reduced_data_out[3] = reduced_bit;
                default: reduced_data_out[DATA_WIDTH-1] = reduced_bit;
            endcase
        end
    endgenerate

endmodule
