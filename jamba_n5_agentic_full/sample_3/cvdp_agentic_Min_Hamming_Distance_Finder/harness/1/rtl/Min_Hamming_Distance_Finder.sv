`timescale 1ns / 1ps

module Min_Hamming_Distance_Finder #(
    parameter BIT_WIDTH = 8,
    parameter REFERENCE_COUNT = 4
) (
    input  wire [BIT_WIDTH-1:0] input_query,
    input  wire [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
    output reg [BIT_WIDTH*CLOG2(REFERENCE_COUNT)-1:0] best_match_index,
    output reg [BIT_WIDTH*CLOG2(REFERENCE_COUNT)-1:0] min_distance
);

    localparam CLOG2_BIT = $clog2(BIT_WIDTH);
    localparam REF_COUNT_LOG2 = $clog2(REFERENCE_COUNT);

    Bit_Difference_Counter #(BIT_WIDTH) bit_diff_counter;
    Data_Reduction data_red;
    Bitwise_Reduction bitwise_red;

    // Array to hold the counters for each reference
    Bit_Difference_Counter #(BIT_WIDTH) inst_list [0 : REFERENCE_COUNT-1];

    initial begin
        // Initialize each instance with the reference vector
        foreach (genvar i; $range(0, REFERENCE_COUNT-1)) begin : bit_counter_for_ref
            assign bit_diff_counter.instance = Bit_Difference_Counter::create_instance(
                .BIT_WIDTH(BIT_WIDTH),
                .REF_COUNT(REF_COUNT)
            );
            bit_diff_counter.instance.assign_input_A(references[$i*BIT_WIDTH]);
            bit_diff_counter.instance.assign_input_B(input_query);
            assign bit_diff_counter.output_bit_difference_count(bit_diff_inst_list[i]);
        end

        // Aggregate the bit differences from all counters
        always @(*) begin
            for (int i = 0; i < REFERENCE_COUNT; i = i + 1) begin
                data_red.reduce(bit_diff_counter.output_bit_difference_count[i*CLOG2_BIT + i*CLOG2_BIT], bit_difference_count[i]);
            end
        end

        // Determine the best match and its distance
        assign best_match_index = $range(0, REFERENCE_COUNT-1);
        assign min_distance = $max_val_between(bit_difference_count[0], bit_difference_count[1]);
        for (int i = 2; i < REFERENCE_COUNT; i = i + 1) begin
            if (bit_difference_count[i] < min_distance) begin
                min_distance = bit_difference_count[i];
                best_match_index = i;
            end
        end
    endinitial

endmodule
