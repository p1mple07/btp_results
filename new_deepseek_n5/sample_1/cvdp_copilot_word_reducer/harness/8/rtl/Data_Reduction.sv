module Bit_Difference_Counter
#(
    parameter [2:0] BIT_WIDTH = 3,
    parameter [2:0] COUNT_WIDTH = 3 // Maximum possible differing bits
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg  [COUNT_WIDTH-1:0] bit_difference_count
);

    // Use Data_Reduction to extract each bit across input_A and input_B
    Data_Reduction
    #(
        parameter [2:0] REDUCTION_OP = 3'b000,
        parameter DATA_WIDTH         = BIT_WIDTH,
        parameter DATA_COUNT         = 2,
        localparam TOTAL_INPUT_WIDTH = DATA_WIDTH * DATA_COUNT
    )
    (
        input  wire [TOTAL_INPUT_WIDTH-1:0] data_in,
        output reg  [DATA_WIDTH-1:0]        reduced_data_out
    );

    wire [BIT_WIDTH-1:0] xor_result;

    // Use Bitwise_Reduction to compute XOR and count set bits
    Bitwise_Reduction
    #(
        parameter [2:0] REDUCTION_OP = 3'b010, // XOR
        parameter BIT_COUNT          = BIT_WIDTH
    )
    (
        input  wire [BIT_COUNT-1:0] input_bits,
        output reg                  reduced_bit
    );

    // Connect the extracted bits to XOR operation
    assign xor_result = reduced_data_out;

    // Count the number of differing bits
    always @(*) begin
        case (reduced_bit)
            1 : bit_difference_count = 1;
            default : bit_difference_count = 0;
        endcase
    end
endmodule