module qam16_demapper_interpolated #(parameter N = 4, parameter OUT_WIDTH = 4, parameter IN_WIDTH = 3)
(
    input signed [(N + N/2) * IN_WIDTH] I,
    input signed [(N + N/2) * IN_WIDTH] Q,
    output logic [(N * OUT_WIDTH) * 1] bits,
    output logic error_flag
);

    // Internal signals
    logic signed [(IN_WIDTH + 1) * 2] mapped_I, mapped_Q;
    logic signed [(IN_WIDTH + 1) * 2] expected_I, expected_Q;
    logic signed [(IN_WIDTH + 1) * 2] diff_I, diff_Q;

    // Split I and Q into mapped and interpolated values
    always_comb begin
        for (int i = 0; i < (N + N/2) * IN_WIDTH; i += IN_WIDTH) begin
            if (i % (IN_WIDTH * 2) < IN_WIDTH) begin
                mapped_I[i / IN_WIDTH] = I[i];
                mapped_Q[i / IN_WIDTH] = Q[i];
            end else begin
                expected_I[i / IN_WIDTH] = mapped_I[i / IN_WIDTH];
                expected_Q[i / IN_WIDTH] = mapped_Q[i / IN_WIDTH];
            end
        end

        // Calculate expected interpolated values
        for (int i = 0; i < (N + N/2) * IN_WIDTH; i += IN_WIDTH * 2) begin
            expected_I[i / IN_WIDTH] = (mapped_I[i / IN_WIDTH] + mapped_I[(i / IN_WIDTH) + 1]) / 2;
            expected_Q[i / IN_WIDTH] = (mapped_Q[i / IN_WIDTH] + mapped_Q[(i / IN_WIDTH) + 1]) / 2;
        end

        // Calculate absolute difference for error detection
        for (int i = 0; i < (N + N/2) * IN_WIDTH; i += IN_WIDTH * 2) begin
            diff_I[i / IN_WIDTH] = |mapped_I[i / IN_WIDTH] - expected_I[i / IN_WIDTH];
            diff_Q[i / IN_WIDTH] = |mapped_Q[i / IN_WIDTH] - expected_Q[i / IN_WIDTH];
        end

        // Set error flag if any differences exceed threshold
        error_flag = (any(diff_I) || any(diff_Q)) ? 1'b1 : 1'b0;

        // Map I and Q components to bits
        for (int i = 0; i < (N * OUT_WIDTH); i += OUT_WIDTH) begin
            bits[i * OUT_WIDTH + 0] = {I[i], Q[i]} <+ 2'b00; // MSBs from I
            bits[i * OUT_WIDTH + 1] = {I[i], Q[i]} <+ 2'b01; // MSBs from Q
            bits[i * OUT_WIDTH + 2] = {I[i], Q[i]} <+ 2'b10; // LSBs from I
            bits[i * OUT_WIDTH + 3] = {I[i], Q[i]} <+ 2'b11; // LSBs from Q
        end
    end
endmodule
