module Min_Hamming_Distance_Finder (
    input [BIT_WIDTH-1:0] input_query,
    input [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
    output [COLLOG2(REFERENCE_COUNT)-1:0] best_match_index,
    output [COLLOG2(BIT_WIDTH+1)-1:0] min_distance
);

    // Helper function to count the number of differing bits
    function [$clog2(BIT_WIDTH+1)-1:0] bit_difference_counter(input [BIT_WIDTH-1:0] a, input [BIT_WIDTH-1:0] b);
        integer i;
        reg [BIT_WIDTH-1:0] xor_val;
        reg [BIT_WIDTH-1:0] count;
        for (i = 0; i < BIT_WIDTH; i = i + 1) begin
            xor_val = a[i] ^ b[i];
            count = count + xor_val;
        end
        return count;
    endfunction

    localparam BIT_COUNT = $rangeOf(references, BIT_WIDTH);
    localparam COUNT_WIDTH = $clog2(BIT_WIDTH + 1);

    reg best_match_index;
    reg min_distance;

    initial begin
        best_match_index = 0;
        min_distance = $inf;

        for (int i = 0; i < BIT_COUNT; i = i + 1) begin
            reg [BIT_WIDTH-1:0] xor_result;
            xor_result = input_query ^ references[i];

            int distance = bit_difference_counter(xor_result, xor_result);

            if (distance < min_distance) begin
                min_distance = distance;
                best_match_index = i;
            end
        end

        $display("Best Match Index: %0d", best_match_index);
        $display("Minimum Distance: %0d", min_distance);
    end

endmodule
