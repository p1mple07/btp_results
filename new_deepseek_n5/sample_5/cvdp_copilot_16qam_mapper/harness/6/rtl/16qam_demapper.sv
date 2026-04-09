module qam16_demapper_interpolated(
    parameter integer N = 4,
    parameter integer OUT_WIDTH = 4,
    parameter integer IN_WIDTH = 3
);

    // Input unpacking logic
    input [((N + N/2) * IN_WIDTH)-1:0] I,
    input [((N + N/2) * IN_WIDTH)-1:0] Q;

    // Output unpacking logic
    output [N*OUT_WIDTH-1:0] bits,
    output error_flag;

    // Process each symbol
    integer i;
    integer mapped_val,
        interpolated_val,
        expected_interpolated_val,
        diff,
        abs_diff,
        error;

    // Unpack I and Q into individual symbols
    for (i = 0; i < N + N/2; i = i + 1) {
        mapped_val = I[((N + N/2) - 1 - i) * IN_WIDTH: i * IN_WIDTH];
        interpolated_val = I[((N + N/2) - 1 - (i + 1)) * IN_WIDTH: (i + 1) * IN_WIDTH];
        expected_interpolated_val = (mapped_val + I[interpolated_val_pos]) / 2;
        diff = interpolated_val - expected_interpolated_val;
        abs_diff = abs(diff);
        if (abs_diff > ERROR_THRESHOLD) {
            error = 1;
        }
    }

    // Map I and Q to bits
    for (i = 0; i < N; i = i + 1) {
        bits[i*OUT_WIDTH: (i*OUT_WIDTH)+OUT_WIDTH-1] = 
            (I_segment_to_bits(mapped_val) << 2) | 
            (Q_segment_to_bits(Q_segment) & 0b11);
    }

    // Set error flag
    error_flag = error;

endmodule