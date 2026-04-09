module qam16_mapper_interpolated(
    parameter integer N,
    parameter integer IN_WIDTH = 4,
    parameter integer OUT_WIDTH = 3
);
    input bit [N*IN_WIDTH-1:0] bits;
    output bit [ (N + N/2)*OUT_WIDTH-1:0 ] I, Q;

    integer i, j;
    bit [IN_WIDTH-1:0] symbol;
    bit [2:1] msb;
    bit [1:0] lsb;
    bit [3:0] mapped_I, mapped_Q;

    integer mapped_I_val, mapped_Q_val;
    integer interpolated_I_val, interpolated_Q_val;

    // Mapping table for I and Q
    localparam map_table = [
        "00" -> -3,
        "01" -> -1,
        "10" -> 1,
        "11" -> 3
    ];

    // Process each symbol
    for (i = 0; i < N; i = i + 1) {
        // Extract symbol
        symbol = bits[ (i * IN_WIDTH) : (i * IN_WIDTH + IN_WIDTH - 1) ];
        
        // Extract MSBs and LSBs
        msb = symbol[3:2];
        lsb = symbol[1:0];
        
        // Map to I and Q
        mapped_I_val = map_table[msb];
        mapped_Q_val = map_table[lsb];
        
        // Store mapped values
        mapped_I[i] = mapped_I_val;
        mapped_Q[i] = mapped_Q_val;
    }

    // Perform interpolation
    for (i = 0; i < N-1; i = i + 1) {
        // Interpolate I
        interpolated_I_val = (mapped_I[i] + mapped_I[i+1]) >> 1;
        
        // Interpolate Q
        interpolated_Q_val = (mapped_Q[i] + mapped_Q[i+1]) >> 1;
        
        // Store interpolated values
        interpolated_I[i] = interpolated_I_val;
        interpolated_Q[i] = interpolated_Q_val;
    }

    // Construct output
    I = (interpolated_I[0] << (OUT_WIDTH)) | mapped_I[0];
    Q = (interpolated_Q[0] << (OUT_WIDTH)) | mapped_Q[0];
    for (j = 1; j < N; j = j + 1) {
        I = (interpolated_I[j] << (OUT_WIDTH)) | mapped_I[j] | (I << (OUT_WIDTH * (j)));
        Q = (interpolated_Q[j] << (OUT_WIDTH)) | mapped_Q[j] | (Q << (OUT_WIDTH * (j)));
    }
endmodule