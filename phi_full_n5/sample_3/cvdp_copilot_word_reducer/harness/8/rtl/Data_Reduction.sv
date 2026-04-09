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


module Bit_Difference_Counter
#(
    parameter BIT_WIDTH = 4
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [BIT_WIDTH-1:0] bit_difference_count
);

    // Calculate the count width based on the BIT_WIDTH
    localparam COUNT_WIDTH = BIT_WIDTH;

    // Instantiate Bitwise_Reduction for XOR operation
    Bitwise_Reduction
    #(
        .REDUCTION_OP (XOR_OP)
    )
    xor_instance
    (
        .input_bits  (input_A, input_B)
    );

    // Count the number of set bits in the XOR result
    always @(*) begin
        bit_difference_count = 0;
        integer i;
        for (i = 0; i < COUNT_WIDTH; i = i + 1) begin : count_iteration
            if (xor_instance.reduced_bit[i]) begin
                bit_difference_count = bit_difference_count + 1;
            end
        end
    end

endmodule
