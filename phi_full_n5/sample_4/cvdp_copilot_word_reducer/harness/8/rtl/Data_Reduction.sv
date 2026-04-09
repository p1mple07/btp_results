module Bit_Difference_Counter
#(
    parameter BIT_WIDTH         = 4, // Default bit width
    parameter COUNT_WIDTH       = BIT_WIDTH, // Output width to represent the Hamming distance
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg [COUNT_WIDTH-1:0] bit_difference_count
);

    generate
        genvar bit_index;

        // Iterate over each bit position within the input vectors
        for (bit_index = 0; bit_index < BIT_WIDTH; bit_index = bit_index + 1) begin : bit_comparison
            wire [COUNT_WIDTH-1:0] diff_bits;

            // Perform bitwise XOR operation between input_A and input_B
            Bitwise_Reduction
            #(
                .REDUCTION_OP (XOR_OP)
            )
            xor_instance
            (
                .input_bits  (input_A[bit_index], input_B[bit_index]),
                .reduced_bit (diff_bits[bit_index])
            );

            // Count the number of set bits (1s) in the result of the XOR operation
            Count_Set_Bits
            #(
                .input_bits  (diff_bits)
            )
            set_bit_counter
            (
                .bit_count   (COUNT_WIDTH),
                .output_bit  (bit_difference_count[bit_index])
            );
        end
    endgenerate

endmodule


module Count_Set_Bits
#(
    parameter BIT_COUNT          = 1, // Default to count single bit
)
(
    input  wire [BIT_COUNT-1:0] input_bits,
    output reg                  bit_count
);

    integer i;
    reg temp_result; // Intermediate result

    always @(*) begin
        // Initialize result with zero
        temp_result = 1'b0;

        // Count set bits in the input
        for (i = 0; i < BIT_COUNT; i = i + 1) begin
            case (input_bits[i])
                '1: temp_result = temp_result + 1'b1;
                default: temp_result = temp_result;
            endcase
        end
    end

    always @(posedge clk) begin
        // Update bit_count with the final count
        bit_count <= temp_result;
    end
endmodule
