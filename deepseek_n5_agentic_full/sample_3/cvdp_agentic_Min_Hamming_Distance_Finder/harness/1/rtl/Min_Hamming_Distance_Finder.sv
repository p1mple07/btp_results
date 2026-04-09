Module instantiation and configuration
module Min_Hamming_Distance_Finder
    #(
        parameter BIT_WIDTH    = 8,
        parameter REFERENCE_COUNT = 4
    )
    
    // Instantiate Bit_Difference_Counter for each reference vector
    Bit_Difference_Counter
    #(
        .BIT_WIDTH  = BIT_WIDTH,
        .DATA_COUNT = REFERENCE_COUNT
    )
    bhc_0 (.input_A = input_query, .input_B = references[0:BIT_WIDTH-1]) \
    bhc_1 (.input_A = input_query, .input_B = references[BIT_WIDTH:2*BIT_WIDTH-1]) \
    bhc_2 (.input_A = input_query, .input_B = references[2*BIT_WIDTH:3*BIT_WIDTH-1]) \
    bhc_3 (.input_A = input_query, .input_B = references[3*BIT_WIDTH:4*BIT_WIDTH-1]);

    // Instantiate the Data_Reduction module
    Data_Reduction
    #(
        .DATA_WIDTH = BIT_WIDTH,
        .DATA_COUNT = REFERENCE_COUNT
    )
    dr
    (
        .data_in = references,
        .reduced_data_out = compare_bits
    );

    // Instantiate Bitwise_Reduction module
    Bitwise_Reduction
    #(
        .BIT_COUNT = REFERENCE_COUNT
    )
    reducer
    (
        .input_bits = compare_bits,
        .reduced_bit = hamming_distances[0]
    );

    // Instantiate the final Bit_Difference_Counter for hamming_distances calculation
    Bit_Difference_Counter
    #(
        .BIT_WIDTH = log2(BIT_WIDTH +1)
    )
    final_bhc (.input_A = hamming_distances, .input_B = 0);

    // Wire the hamming_distances to final_bhc
    hamming_distances -> final_bhc.input_A;

    // Output wires
    best_match_index out,
    min_distance out
endmodule