module qam16_demapper_interpolated #(parameter N = 4, parameter OUT_WIDTH = 4, parameter IN_WIDTH = 3) (
    input logic [(N + N/2) * IN_WIDTH - 1:0] I,
    input logic [(N + N/2) * IN_WIDTH - 1:0] Q,
    output logic [(N - 1) * OUT_WIDTH - 1:0] bits,
    output logic error_flag
);

    logic [IN_WIDTH - 1:0] mapped_i, mapped_q;
    logic [IN_WIDTH - 1:0] expected_i, expected_q;
    logic [IN_WIDTH - 1:0] diff_i, diff_q;

    // Parsing input I and Q components
    always_comb begin
        for (int i = 0; i < (N + N/2) * IN_WIDTH; i += 2 * IN_WIDTH) begin
            mapped_i = I[i + IN_WIDTH - 1:0];
            mapped_q = Q[i + IN_WIDTH - 1:0];

            // Calculate expected interpolated values
            expected_i = (mapped_i + mapped_i) >> IN_WIDTH;
            expected_q = (mapped_q + mapped_q) >> IN_WIDTH;

            // Calculate deviations
            diff_i = mapped_i - expected_i;
            diff_q = mapped_q - expected_q;

            // Check for errors
            if (abs(diff_i) > ERROR_THRESHOLD || abs(diff_q) > ERROR_THRESHOLD) begin
                error_flag = 1'b1;
            end
        end
    end

    // Mapping I/Q components to bits
    always_comb begin
        for (int i = 0; i < (N - 1) * OUT_WIDTH; i += OUT_WIDTH) begin
            // Convert I and Q to bits
            bits[i + OUT_WIDTH - 1:i] = {mapped_i[IN_WIDTH - 1:1], mapped_q[IN_WIDTH - 1:1]};
        end
    end

endmodule
