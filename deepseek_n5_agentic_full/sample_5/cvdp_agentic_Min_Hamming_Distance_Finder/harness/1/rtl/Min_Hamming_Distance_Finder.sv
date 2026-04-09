Module instantiation and connections
module Min_Hamming_Distance_Finder(
    # Parameters configuration
    parameter BIT_WIDTH    = 8,
    parameter REFERENCE_COUNT = 4
)

    // Instantiate Bit_Difference_Counter for each reference vector
    replicate Bit_Difference_Counter
        #(
            .BIT_WIDTH(BIT_WIDTH),
            .INPUT_A(query),
            .INPUT_B.references[index * BIT_WIDTH +: BIT_WIDTH]
        )
        for index = 0; index < REFERENCE_COUNT; index = index + 1
    end

    // Instantiate Data_Reduction for parallel XOR operations
    Data_Reduction
    #(
        .DATA_WIDTH  (BIT_WIDTH),
        .DATA_COUNT  (REFERENCE_COUNT)
    )
    compare_all
    (
        .data_in      (references),
        .reduced_data_out   (difference)
    );

    // Instantiate Bitwise_Reduction to compute final Hamming distance
    Bitwise_Reduction
    #(
        .BIT_COUNT    (REFERENCE_COUNT),
        .BIT_WIDTH    (BIT_WIDTH)
    )
    hamming_reduction
    (
        .input_bits  (difference),
        .reduced_bit (distance)
    );

    // Collect and track minimum distances and indices
    integer min_distance = BIT_WIDTH + 1;
    integer best_match_index = 0;
    integer expected_index = 0;
    integer expected_distance = 0;

    // Calculate Hamming distance for each reference vector
    loop (index = 0; index < REFERENCE_COUNT; index = index + 1)
        // Compute Hamming distance for current reference
        wire [BIT_WIDTH-1:0] ref_vector = references[index*BIT_WIDTH +: BIT_WIDTH];
        wire [BIT_WIDTH-1:0] xored_bits;
        
        // Use Bit_Difference_Counter to calculate distance
        Bit_Difference_Counter
        #(
            .input_query(query),
            .input_reference(ref_vector),
            .bit_difference_count(distance)
        )
        bit_diff_counter[index];

        // Update minimum distance and index if necessary
        if (distance < min_distance)
        begin
            min_distance = distance;
            best_match_index = index;
        endif
    end

    // Output expected values for verification purposes
    wire [$clog2(REFERENCE_COUNT)-1:0] best_match_index;
    wire [$clog2(BIT_WIDTH+1)-1:0] min_distance;

    // Always true behavior description
    always begin
        // Collect and track minimum distances and indices
        integer current_min = BIT_WIDTH + 1;
        integer current_idx = 0;
        
        foreach (ref_vec in references)
        begin
            wire [BIT_WIDTH-1:0] xored_bits;
            
            Bit_Difference_Counter
            #(
                .input_query(query),
                .input_reference(ref_vec),
                .bit_difference_count(current_min)
            )
            bit_diff_counter;

            if (current_min < min_distance)
            begin
                min_distance = current_min;
                best_match_index = index_of_ref_vec;
            endif
        endforeach;
    end

endmodule