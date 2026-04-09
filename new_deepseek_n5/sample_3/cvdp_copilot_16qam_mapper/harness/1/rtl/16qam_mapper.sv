module qam16_mapper_interpolated(
    parameter integer N = 4,
    parameter integer IN_WIDTH = 4,
    parameter integer OUT_WIDTH = 3
)
    input bit [N * IN_WIDTH - 1: 0] bits,
    output bit [ (N + N/2) * OUT_WIDTH - 1: 0 ] I,
    output bit [ (N + N/2) * OUT_WIDTH - 1: 0 ] Q
);

    integer i, j;
    integer mapped_I, mapped_Q;
    integer prev_I, prev_Q;

    // Initialize output bitstream
    bit [ (N + N/2) * OUT_WIDTH - 1: 0 ] output_bitstream = 0;

    // Process each symbol
    for (i = 0; i < N; i++) {
        // Extract I and Q components
        mapped_I = (bits[ (i * IN_WIDTH) + 2: (i * IN_WIDTH) + 1 ]) ? 3 : 
                   (bits[ (i * IN_WIDTH) + 2: (i * IN_WIDTH) + 1 ]) ? 1 :
                   (bits[ (i * IN_WIDTH) + 2: (i * IN_WIDTH) + 1 ]) ? -1 :
                   -3;
        mapped_Q = (bits[ (i * IN_WIDTH) + 0: (i * IN_WIDTH) - 1 ]) ? 3 :
                   (bits[ (i * IN_WIDTH) + 0: (i * IN_WIDTH) - 1 ]) ? 1 :
                   (bits[ (i * IN_WIDTH) + 0: (i * IN_WIDTH) - 1 ]) ? -1 :
                   -3;

        // Compute interpolation
        if (i > 0) {
            prev_I = prev_I >> 1;
            prev_Q = prev_Q >> 1;
        } else {
            prev_I = mapped_I;
            prev_Q = mapped_Q;
        }

        // Pack output
        output_bitstream = output_bitstream << OUT_WIDTH;
        output_bitstream = output_bitstream | (mapped_I << (OUT_WIDTH - 1));
        output_bitstream = output_bitstream | (mapped_Q << (OUT_WIDTH - 1));
        output_bitstream = output_bitstream | (prev_I << (OUT_WIDTH - 1));
        output_bitstream = output_bitstream | (prev_Q << (OUT_WIDTH - 1));

        // Update previous values
        prev_I = mapped_I;
        prev_Q = mapped_Q;
    }

    output_bitstream = output_bitstream [ (N + N/2) * OUT_WIDTH - 1: 0 ];

endmodule