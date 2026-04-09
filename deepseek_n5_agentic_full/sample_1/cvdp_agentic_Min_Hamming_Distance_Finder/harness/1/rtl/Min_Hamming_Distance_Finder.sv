// Module instantiation and configuration
module Min_Hamming_Distance_Finder
    (parameter BIT_WIDTH, parameter REFERENCE_COUNT)
    (input [BIT_WIDTH-1:0] input_query,
     input [REFERENCE_COUNT*BIT_WIDTH-1:0] references,
     output [$clog2(BIT_WIDTH+1)-1:0] best_match_index,
     output [$clog2(BIT_WIDTH+1)-1:0] min_distance)
{
    // Instantiate Bit Difference Counters for each reference vector
    array refrs [0:REFERENCE_COUNT-1] of wire [BIT_WIDTH-1:0];
    
    foreach(i_ref in 0..REFERENCE_COUNT-1)
        Min_Hamming_Distance_Finder_BIT Differential Counter
            (.input_A(input_query)
             .input_B(references[i_ref*BIT_WIDTH:(i_ref*BIT_WIDTH)+BIT_WIDTH])
             .output(bit_difference_count))
    end

    // Determine the best match index and minimum distance
    register [REFERENCE_COUNT-1:0] best_match_index;
    register [$clog2(BIT_WIDTH+1)-1:0] min_distance;
    register [(Bit_width - 1):0] min_distance_reg;

    wire [REFERENCE_COUNT-1:0] distance_array;
    wire [Bit_width-1:0] final_distance;

    foreach(i_ref in 0..REFERENCE_COUNT-1)
        wire distance_array[i_ref] -> final_distance;
    end

    // Calculate minimum distance and best match index
    integer i;
    min_distance = $maxval;
    best_match_index = 0;

    for(i=0; i<REFRENCE_COUNT; i=i+1)
    {
        if(final_distance[i] < min_distance)
        {
            min_distance = final_distance[i];
            best_match_index = i;
        }
    }

    // Output signals
    best_match_index <= best_match_index;
    min_distance <= min_distance;
}

// Description
// Module computes the minimum Hamming distance between an input query vector and a set of reference vectors.
// Outputs the index of the reference vector with the smallest Hamming distance and the corresponding distance value.
//
// Parameters:
// BIT_WIDTH - Number of bits in each vector
// REFERENCE_COUNT - Number of reference vectors
// Input:
// input_query - The query vector to compare against references
// references - Concatenated reference vectors
// Output:
// best_match_index - Index of the reference vector with minimum distance
// min_distance - The minimum Hamming distance found
rtl/Min_Hamming_Distance_Finder.sv