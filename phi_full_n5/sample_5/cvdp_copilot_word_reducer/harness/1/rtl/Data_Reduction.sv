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

            // Extract bits for the current bit position from all data elements
            for (int i = 0; i < DATA_COUNT; i = i + 1) begin
                extracted_bits[i] = data_in[(bit_index * DATA_COUNT) + i];
            end

            // Use Bitwise_Reduction module to perform reduction operation
            wire [DATA_COUNT-1:0] reduction_result;
            Bitwise_Reduction reduction_inst(REDUCTION_OP, BIT_COUNT);
            assign reduction_result = reduction_inst.reduced_bit;

            // Combine the results to form the final reduced output bit
            case (bit_index)
                0: reduced_data_out[0] = reduction_result;
                1: reduced_data_out[1] = reduction_result;
                2: reduced_data_out[2] = reduction_result;
                3: reduced_data_out[3] = reduction_result;
                default: reduced_data_out = { {reduced_data_out, 0}}; // Padding with zero if bit_index is out of range
            endcase
        end
    endgenerate

endmodule

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

        // Assign the reduced bit to the output
        reduced_bit = temp_result;
    end
endmodule
