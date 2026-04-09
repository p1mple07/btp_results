module qam16_mapper_interpolated(
    parameter N = 4,
    parameter IN_WIDTH = 4,
    parameter OUT_WIDTH = 3
);
    input bit [N*IN_WIDTH-1:0] bits;
    output bit [(N + N/2)*OUT_WIDTH-1:0] I, Q;

    // Mapping logic
    integer mapped_I, mapped_Q;
    integer interp_I, interp_Q;
    integer i;

    // Process each symbol
    for (i = 0; i < N; i++) {
        // Extract I and Q components from current symbol
        mapped_I = (bits[(4*i + 3)*2] >> 2) ? (-3) : ((bits[(4*i + 3)*2] >> 2) ? (-1) : ( (bits[(4*i + 3)*2] >> 2) ? 1 : 3 ));
        mapped_Q = (bits[(4*i + 1)*2] >> 2) ? (-3) : ((bits[(4*i + 1)*2] >> 2) ? (-1) : ( (bits[(4*i + 1)*2] >> 2) ? 1 : 3 ));

        // Store mapped values
        I[((2*i) * OUT_WIDTH):0] = mapped_I;
        Q[((2*i) * OUT_WIDTH):0] = mapped_Q;

        // If not last symbol, compute interpolation
        if (i < N-1) {
            interp_I = (mapped_I + mapped_I_next) >> 1;
            interp_Q = (mapped_Q + mapped_Q_next) >> 1;
            I[((2*i + 1) * OUT_WIDTH):0] = interp_I;
            Q[((2*i + 1) * OUT_WIDTH):0] = interp_Q;
        }
    }
endmodule