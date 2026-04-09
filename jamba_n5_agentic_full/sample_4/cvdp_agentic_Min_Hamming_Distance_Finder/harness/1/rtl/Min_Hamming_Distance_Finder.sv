// rtl/Min_Hamming_Distance_Finder.sv
module Min_Hamming_Distance_Finder (
    input  wire [BIT_WIDTH-1:0] input_query,
    input  wire [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
    output reg  [BIT_WIDTH*COMBINATIONS-1:0] best_match_index,
    output reg  [BIT_WIDTH*COMBINATIONS-1:0] min_distance
);

    // Parameter values
    localparam BIT_WIDTH = 8;
    localparam REFERENCE_COUNT = 4;
    localparam COMBINATIONS = BIT_WIDTH * REFERENCE_COUNT;

    // Counter module for each reference vector
    Bit_Difference_Counter #(.BIT_WIDTH(BIT_WIDTH)) inst_0 (
        .input_A(input_query),
        .input_B(references[0*BIT_WIDTH + : BIT_WIDTH]),
        .output_difference(diff0)
    );
    Bit_Difference_Counter #(.BIT_WIDTH(BIT_WIDTH)) inst_1 (
        .input_A(input_query),
        .input_B(references[1*BIT_WIDTH + : BIT_WIDTH]),
        .output_difference(diff1)
    );
    // Add remaining counters ...

    // Accumulate the bit differences
    data_type [DATA_COUNT-1:0] diff_total = {0};

    // Process each reference vector
    foreach (inst_i; 0 to COMBINATIONS-1) begin : iter_counter
        diff_total[inst_i*BIT_WIDTH] = diff_total[inst_i*BIT_WIDTH] + inst_i.output_difference[inst_i];
    end

    // Compute the Hamming distance count
    always @(*) begin
        bit_difference_count = 0;
        for (bit_index = 0; bit_index < BIT_WIDTH; bit_index = bit_index + 1) begin
            bit_difference_count = bit_difference_count + diff_total[bit_index];
        end
    end

    // Find the best match
    always @(*) begin
        best_match_index = 0;
        min_distance = BIT_WIDTH + 1;
        for (bit_index = 0; bit_index < BIT_WIDTH*COMBINATIONS; bit_index = bit_index + 1) begin
            if (bit_difference_count < min_distance) begin
                min_distance = bit_difference_count;
                best_match_index = bit_index;
            end
        end
    end

endmodule
