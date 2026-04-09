module Bit_Difference_Counter
#(
    parameter BIT_WIDTH         = 4, // Default bit width for input vectors
    parameter COUNT_WIDTH       = BIT_WIDTH // Calculate count width based on BIT_WIDTH
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    // Create a temporary vector for XOR operation
    wire [BIT_WIDTH-1:0] xor_result;

    // Use Data_Reduction to perform bitwise XOR and count differing bits
    generate
        genvar bit_index;

        // Iterate over each bit position within a single input vector
        for (bit_index = 0; bit_index < BIT_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            wire [BIT_WIDTH-1:0] temp_vector;

            // Create temporary vectors with all zeros except the current bit
            assign temp_vector[bit_index] = input_A[bit_index];
            assign temp_vector[(BIT_WIDTH - 1) - bit_index] = input_B[bit_index];

            // Perform XOR operation using Data_Reduction
            Data_Reduction
            #(
                .REDUCTION_OP(3'b010), // XOR operation
                .DATA_WIDTH(BIT_WIDTH)
            )
            xor_reducer
            (
                .input_bits  (temp_vector),
                .reduced_bit (xor_result[bit_index])
            );
        end

        // Count the number of set bits in the XOR result
        bit_counting
            #(
                .DATA_WIDTH(BIT_WIDTH)
            )
            xor_counter
            (
                .input_bits  (xor_result),
                .count       (bit_difference_count)
            );
    endgenerate

endmodule


module Bit_Counting
#(
    parameter DATA_WIDTH = 4
)
(
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] count
);

    integer i;
    reg temp_count; // Intermediate count result

    always @(*) begin
        temp_count = 0;
        for (i = 0; i < DATA_WIDTH; i = i + 1) begin
            case (data_in[i])
                '1: temp_count = temp_count + 1;
                default:
                endcase
        end
        count = temp_count;
    end

endmodule


module Data_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b010, // Default operation: XOR
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


module Bitwise_Reduction
#(
    parameter [2:0] REDUCTION_OP = 3'b010, // Default operation: XOR
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

    integer i;
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

        // Apply final inversion if required
        case (REDUCTION_OP)
            NAND_OP : reduced_bit = ~temp_result;
            NOR_OP  : reduced_bit = ~temp_result;
            XNOR_OP : reduced_bit = ~temp_result;
            default : reduced_bit = temp_result;
        endcase
    end
endmodule
