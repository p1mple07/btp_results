module Min_Hamming_Distance_Finder #(
    parameter BIT_WIDTH = 8,
    parameter REFERENCE_COUNT = 4
) (
    input  wire [BIT_WIDTH-1:0] input_query,
    input  wire [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
    output reg [COLLOG2(REFERENCE_COUNT)-1:0] best_match_index,
    output reg [COLLOG2(BIT_WIDTH+1)-1:0] min_distance
);
