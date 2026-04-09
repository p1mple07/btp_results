// --- rtl/Min_Hamming_Distance_Finder.sv ---------------------------------
module Min_Hamming_Distance_Finder #(
    parameter BIT_WIDTH = 8,
    parameter REFERENCE_COUNT = 4
) (
    input  wire [BIT_WIDTH-1:0] input_query,
    input  wire [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
    output reg [REFERENCE_COUNT-1:0] best_match_index,
    output reg [REFERENCE_COUNT-1:0] min_distance
);

    // Instantiate a Bit_Difference_Counter for each reference vector
    Bit_Difference_Counter u1 (
        .REDUCTION_OP(3'b010),
        .DATA_WIDTH(BIT_WIDTH),
        .DATA_COUNT(2)
    );

    Bit_Difference_Counter u2 (
        .REDUCTION_OP(3'b010),
        .DATA_WIDTH(BIT_WIDTH),
        .DATA_COUNT(2)
    );

    // Counters for Hamming distances
    reg [REFERENCE_COUNT-1:0] dists = { [0:REFERENCE_COUNT-1] 16'hFFFF };
    reg best_dist = 16'd32768;
    reg best_idx = 0;

    // Evaluate each reference vector
    for (genvar i = 0; i < REFERENCE_COUNT; i = i + 1) begin : loop
        Bit_Difference_Counter u = new (#5);
        u.input_A = input_query;
        u.input_B = references[i*BIT_WIDTH : (i+1)*BIT_WIDTH];
        u.output_bit_difference_count = dists[i];

        if (u.output_bit_difference_count < best_dist) begin
            best_dist = u.output_bit_difference_count;
            best_idx = i;
        end
    end

    assign best_match_index = best_idx;
    assign min_distance = best_dist;

endmodule
