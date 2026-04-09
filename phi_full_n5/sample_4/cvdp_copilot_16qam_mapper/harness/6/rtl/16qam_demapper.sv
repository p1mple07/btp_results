module qam16_demapper_interpolated #(parameter N = 4, parameter OUT_WIDTH = 4, parameter IN_WIDTH = 3)
(
    input logic [(N + N/2) * IN_WIDTH - 1:0] I,
    input logic [(N + N/2) * IN_WIDTH - 1:0] Q,
    output logic [N*OUT_WIDTH - 1:0] bits,
    output logic error_flag
);

    logic [IN_WIDTH-1:0] mapped_I, mapped_Q, interpolated_I, interpolated_Q;
    logic [IN_WIDTH-1:0] expected_I, expected_Q;
    logic [IN_WIDTH-1:0] diff_I, diff_Q;

    // Split input vectors into mapped and interpolated components
    always_comb begin
        for (int i = 0; i < (N + N/2); i += 2) begin
            mapped_I = I[(i*IN_WIDTH + 0) +: IN_WIDTH];
            mapped_Q = Q[(i*IN_WIDTH + 0) +: IN_WIDTH];

            if (i < N) begin
                interpolated_I = I[(i*IN_WIDTH + 1) +: IN_WIDTH];
                interpolated_Q = Q[(i*IN_WIDTH + 1) +: IN_WIDTH];

                expected_I = (mapped_I + mapped_I) / 2;
                expected_Q = (mapped_Q + mapped_Q) / 2;
            end
        end
    end

    // Calculate the difference and detect errors
    always_comb begin
        for (int i = 0; i < N; i++) begin
            diff_I = |(interpolated_I - expected_I) + 1'b0;
            diff_Q = |(interpolated_Q - expected_Q) + 1'b0;

            // Set error flag if error threshold is exceeded
            if (diff_I > ERROR_THRESHOLD) begin
                error_flag = 1'b1;
            end
            if (diff_Q > ERROR_THRESHOLD) begin
                error_flag = 1'b1;
            end

            // Map I and Q to bits
            bits[(i*OUT_WIDTH) +: OUT_WIDTH] = {(mapped_I >> (IN_WIDTH - 2)) | (interpolated_I >> (IN_WIDTH - 2)) | (mapped_Q >> (IN_WIDTH - 2))};
        end
    end

endmodule
