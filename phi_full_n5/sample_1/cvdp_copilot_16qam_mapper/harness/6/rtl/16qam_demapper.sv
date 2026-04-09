module qam16_demapper_interpolated #(parameter N = 4, parameter OUT_WIDTH = 4, parameter IN_WIDTH = 3) (
    input logic [(N + N/2) * IN_WIDTH - 1 : 0] I,
    input logic [(N + N/2) * IN_WIDTH - 1 : 0] Q,
    output logic [(N - 1) * OUT_WIDTH : 0] bits,
    output logic error_flag
);

    logic [IN_WIDTH - 1 : 0] mapped_I, mapped_Q, interpolated_I, interpolated_Q;
    logic [IN_WIDTH - 1 : 0] expected_I, expected_Q;
    logic [IN_WIDTH - 1 : 0] deviation_I, deviation_Q;
    logic [IN_WIDTH - 1 : 0] bit_I, bit_Q;

    integer i;

    // Input parsing
    for (i = 0; i < (N + N/2) * IN_WIDTH; i += IN_WIDTH) begin
        mapped_I = I[(i + 0) * IN_WIDTH - 1 : IN_WIDTH - 1];
        mapped_Q = Q[(i + 0) * IN_WIDTH - 1 : IN_WIDTH - 1];
        interpolated_I = I[(i + 1) * IN_WIDTH - 1 : IN_WIDTH];
        interpolated_Q = Q[(i + 1) * IN_WIDTH - 1 : IN_WIDTH];

        // Expected interpolated values
        expected_I = (mapped_I + mapped_I) / 2;
        expected_Q = (mapped_Q + mapped_Q) / 2;

        // Error detection
        deviation_I = |(interpolated_I - expected_I) / 2;
        deviation_Q = |(interpolated_Q - expected_Q) / 2;

        if (deviation_I > ERROR_THRESHOLD) begin
            error_flag = 1;
        end
        if (deviation_Q > ERROR_THRESHOLD) begin
            error_flag = 1;
        end

        // Mapping I/Q components to bits
        bit_I = {expected_I, mapped_I};
        bit_Q = {expected_Q, mapped_Q};

        // Output arrangement
        for (int j = 0; j < N; j++) begin
            bits[(j - 1) * OUT_WIDTH +: OUT_WIDTH] = bit_I[(j * IN_WIDTH - 1) | (j * IN_WIDTH)];
            bits[(j - 1) * OUT_WIDTH +: OUT_WIDTH] = bit_Q[(j * IN_WIDTH - 1) | (j * IN_WIDTH)];
        end
    end
endmodule
