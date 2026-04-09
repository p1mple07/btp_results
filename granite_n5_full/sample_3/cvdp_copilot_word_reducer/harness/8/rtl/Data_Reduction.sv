module Bit_Difference_Counter
#(
    parameter BIT_WIDTH = 3,            // Width of input vectors
    parameter COUNT_WIDTH = $clog2(BIT_WIDTH) // Calculate COUNT_WIDTH based on BIT_WIDTH
)
(
    input  wire [BIT_WIDTH-1:0] input_A,
    input  wire [BIT_WIDTH-1:0] input_B,
    output reg  [COUNT_WIDTH-1:0] bit_difference_count
);

    wire [BIT_WIDTH-1:0] xor_result; // Result of bitwise XOR operation

    generate
        // Generate parallel instances of Data_Reduction for each bit position
        genvar bit_index;
        for (bit_index = 0; bit_index < BIT_WIDTH; bit_index = bit_index + 1) begin : bit_processing
            Data_Reduction
            #(
               .REDUCTION_OP (XOR_OP),  // Use XOR operation for bitwise reduction
               .BIT_COUNT     (1)       // Only process one bit at a time
            )
            reduction_instance
            (
               .input_bits  (input_A[bit_index]),
               .reduced_bit (xor_result[bit_index])
            );
        end
    endgenerate

    // Count the number of set bits in the XOR result
    always @(*) begin
        bit_difference_count = 0;
        
        for (int i = 0; i < BIT_WIDTH; i = i + 1) begin
            if (xor_result[i] == 1) begin
                bit_difference_count = bit_difference_count + 1;
            end
        end
    end

endmodule