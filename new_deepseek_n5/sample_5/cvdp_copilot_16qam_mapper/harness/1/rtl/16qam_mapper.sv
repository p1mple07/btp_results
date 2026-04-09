module qam16_mapper_interpolated(
    parameter integer N = 4,
    parameter integer IN_WIDTH = 4,
    parameter integer OUT_WIDTH = 3
);

    input bit [N*IN_WIDTH-1:0] bits;
    output signed [ (N + N/2)*OUT_WIDTH -1 : 0 ] I, Q;

    // Mapping tables
    localparam map_I = [
        0b00 => -3,
        0b01 => -1,
        0b10 => 1,
        0b11 => 3
    ];
    localparam map_Q = [
        0b00 => -3,
        0b01 => -1,
        0b10 => 1,
        0b11 => 3
    ];

    // Register to hold mapped symbols
    reg signed [IN_WIDTH-1:0] mapped_symbols[N];

    // Register to hold interpolated symbols
    reg signed [OUT_WIDTH-1:0] interpolated_symbols[N/2];

    // Register to hold output symbols
    reg signed [ (N + N/2)*OUT_WIDTH -1 : 0 ] I_reg, Q_reg;

    integer i, j;

    // Mapping input symbols
    for (i = 0; i < N; i++) {
        // Extract MSBs for I
        mapped_symbols[i] = bits[ (i*IN_WIDTH + 1)*2 : (i*IN_WIDTH + 1)*2 + 1 ];
        // Extract LSBs for Q
        mapped_symbols[i] = mapped_symbols[i] ? map_I[mapped_symbols[i]] : 0;
    }

    // Interpolation
    for (i = 0; i < N/2; i++) {
        // Compute interpolated I
        signed [OUT_WIDTH-1:0] sum_I = (signed) ( (I_reg >> (OUT_WIDTH*(i+1))) + (I_reg >> (OUT_WIDTH*i)) );
        interpolated_symbols[i] = sum_I / 2;
        // Compute interpolated Q
        signed [OUT_WIDTH-1:0] sum_Q = (signed) ( (Q_reg >> (OUT_WIDTH*(i+1))) + (Q_reg >> (OUT_WIDTH*i)) );
        interpolated_symbols[i] = interpolated_symbols[i] ? interpolated_symbols[i] : 0;
    }

    // Build output vectors
    I_reg = 0;
    Q_reg = 0;
    for (i = 0; i < N; i++) {
        I_reg = I_reg << (OUT_WIDTH*(i+1)) | mapped_symbols[i];
        Q_reg = Q_reg << (OUT_WIDTH*(i+1)) | interpolated_symbols[i];
    }

endmodule