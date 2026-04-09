module qam16_demapper_interpolated(
    parameter integer N,
    parameter integer OUT_WIDTH = 4,
    parameter integer IN_WIDTH = 3
);
    input I,
    input Q;
    output bits,
    output error_flag;

    // Calculate the number of mapped and interpolated symbols
    integer num_symbols = N + (N / 2);
    integer num_bits = N * OUT_WIDTH;

    // Extract mapped and interpolated values
    integer mapped_I[num_symbols], mapped_Q[num_symbols];
    integer interpolated_I[num_symbols], interpolated_Q[num_symbols];

    // Process each symbol
    for (integer i = 0; i < num_symbols; i++) {
        mapped_I[i] = I[((i * (IN_WIDTH + (IN_WIDTH / 2))) + i) : ((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 1)) * IN_WIDTH];
        mapped_Q[i] = Q[((i * (IN_WIDTH + (IN_WIDTH / 2))) + i) : ((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 1)) * IN_WIDTH];
        interpolated_I[i] = I[((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 1)) : ((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 2)) * IN_WIDTH];
        interpolated_Q[i] = Q[((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 1)) : ((i * (IN_WIDTH + (IN_WIDTH / 2))) + (i + 2)) * IN_WIDTH];
    }

    // Calculate expected interpolated values
    integer expected_I[num_symbols], expected_Q[num_symbols];
    for (integer i = 0; i < num_symbols; i++) {
        if (i == 0) {
            expected_I[i] = mapped_I[i];
        } else if (i == num_symbols - 1) {
            expected_I[i] = mapped_I[i];
        } else {
            expected_I[i] = (mapped_I[i - 1] + mapped_I[i]) / 2;
        }
        if (i == 0) {
            expected_Q[i] = mapped_Q[i];
        } else if (i == num_symbols - 1) {
            expected_Q[i] = mapped_Q[i];
        } else {
            expected_Q[i] = (mapped_Q[i - 1] + mapped_Q[i]) / 2;
        }
    }

    // Calculate differences and check errors
    integer diff_I[num_symbols], diff_Q[num_symbols];
    integer abs_diff[num_symbols];
    error_flag = 0;
    for (integer i = 0; i < num_symbols; i++) {
        diff_I[i] = interpolated_I[i] - expected_I[i];
        diff_Q[i] = interpolated_Q[i] - expected_Q[i];
        abs_diff[i] = abs(diff_I[i]) + abs(diff_Q[i]);
        if (abs_diff[i] > ERROR_THRESHOLD) {
            error_flag = 1;
        }
    }

    // Convert I and Q to bits
    integer bits_I[2], bits_Q[2];
    for (integer i = 0; i < num_symbols; i++) {
        bits_I[0] = (mapped_I[i] >> (IN_WIDTH - 1)) & 0b10;
        bits_I[1] = (mapped_I[i] >> (IN_WIDTH - 2)) & 0b11;
        bits_Q[0] = (mapped_Q[i] >> (IN_WIDTH - 1)) & 0b10;
        bits_Q[1] = (mapped_Q[i] >> (IN_WIDTH - 2)) & 0b11;
    }

    // Pack bits into output vector
    bits = bits_I[1] | (bits_I[0] << 2) | bits_Q[1] | (bits_Q[0] << 2);
endmodule