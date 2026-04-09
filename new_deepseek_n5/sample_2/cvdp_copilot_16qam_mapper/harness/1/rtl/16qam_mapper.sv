module qam16_mapper_interpolated(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
);

    input bit [N*IN_WIDTH-1:0] bits;
    output bit [ (N + N/2)*OUT_WIDTH-1:0 ] I, Q;

    // Mapping table
    localparam map_table = [
        {3, 3},
        {1, 1},
        {-1, -1},
        {-3, -3}
    ];

    // Intermediate storage for interpolated values
    bit [OUT_WIDTH-1:0] prev_I, prev_Q;

    // Output vectors
    bit [OUT_WIDTH-1:0] I_out, Q_out;

    // Process each symbol
    integer i;
    for (i = 0; i < N; i++) {
        // Extract I and Q components from current symbol
        bit [3:2] msb = bits[4*i + 3:4*i + 2];
        bit [1:0] lsb = bits[4*i + 1:4*i];
        
        // Map to I and Q
        I_out = map_table[msb][0];
        Q_out = map_table[lsb][1];
        
        // Store for interpolation
        prev_I = I_out;
        prev_Q = Q_out;
        
        // Interpolate with previous symbol
        if (i > 0) {
            bit [OUT_WIDTH+1-1:0] temp_I = (I_out + prev_I);
            bit [OUT_WIDTH+1-1:0] temp_Q = (Q_out + prev_Q);
            
            I_out = temp_I >> 1;
            Q_out = temp_Q >> 1;
        }
        
        // Pack outputs
        I_out_vec[i*2] = I_out;
        Q_out_vec[i*2+1] = Q_out;
        
        // Update previous values
        prev_I = I_out;
        prev_Q = Q_out;
    }

    // Assign output vectors
    I = I_out_vec;
    Q = Q_out_vec;

endmodule