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

    // Intermediate wire to hold the output bits from each Bitwise_Reduction instance
    wire [DATA_WIDTH-1:0] bit_reduction_out;

    generate
        genvar bit_index;
        for (bit_index = 0; bit_index < DATA_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            // Extract the corresponding bits from each data element.
            // For each data element, the bit at position "bit_index" is located at index (j*DATA_WIDTH + bit_index)
            wire [DATA_COUNT-1:0] extracted_bits;
            genvar j;
            for (j = 0; j < DATA_COUNT; j = j + 1) begin : extract_loop
                assign extracted_bits[j] = data_in[j*DATA_WIDTH + bit_index];
            end

            // Instantiate Bitwise_Reduction for the current bit position.
            Bitwise_Reduction #(
                .REDUCTION_OP(REDUCTION_OP),
                .BIT_COUNT(DATA_COUNT)
            ) bit_reducer_inst (
                .input_bits(extracted_bits),
                .reduced_bit(bit_reduction_out[bit_index])
            );
        end
    endgenerate

    // Combine the outputs from all Bitwise_Reduction modules into the final reduced data output.
    always_comb begin
        reduced_data_out = bit_reduction_out;
    end

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
        // Initialize result with the first bit.
        temp_result = input_bits[0];

        // Reduce bits using the selected operation.
        for (i = 1; i < BIT_COUNT; i = i + 1) begin
            case (REDUCTION_OP)
                AND_OP, NAND_OP  : temp_result = temp_result & input_bits[i];
                OR_OP,  NOR_OP   : temp_result = temp_result | input_bits[i];
                XOR_OP, XNOR_OP  : temp_result = temp_result ^ input_bits[i];
                default          : temp_result = temp_result & input_bits[i];
            endcase
        end

        // For NAND, NOR, and XNOR operations, invert the result.
        case (REDUCTION_OP)
            NAND_OP: reduced_bit = ~temp_result;
            NOR_OP : reduced_bit = ~temp_result;
            XNOR_OP: reduced_bit = ~temp_result;
            default: reduced_bit = temp_result;
        endcase
    end

endmodule