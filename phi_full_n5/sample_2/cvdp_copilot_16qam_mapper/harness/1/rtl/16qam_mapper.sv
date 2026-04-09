module qam16_mapper_interpolated #(parameter N = 4, parameter IN_WIDTH = 4, parameter OUT_WIDTH = 3)
(
    input  logic [N*IN_WIDTH-1:0] bits,
    output logic [(N + N/2)*OUT_WIDTH-1:0] I,
    output logic [(N + N/2)*OUT_WIDTH-1:0] Q
);

    // Internal signals for interpolation
    logic [OUT_WIDTH-1:0] interpolated_I, interpolated_Q;

    // Mapping and interpolation logic
    genvar i, j;
    always_comb begin
        for (i = 0; i < N; i = i + 1) begin
            // Extract MSBs and LSBs for current symbol
            logic [IN_WIDTH-1:0] symbol_I_msb = bits[(i*IN_WIDTH)-IN_WIDTH+1:IN_WIDTH-1];
            logic [IN_WIDTH-1:0] symbol_I_lsb = bits[(i*IN_WIDTH)-1:0];
            logic [IN_WIDTH-1:0] symbol_Q_msb = symbol_I_msb;
            logic [IN_WIDTH-1:0] symbol_Q_lsb = symbol_I_lsb;

            // Map I and Q components
            interpolated_I[i*OUT_WIDTH] = symbol_I_msb * 3 - 3;
            interpolated_I[(i+1)*OUT_WIDTH-1] = symbol_I_lsb * 3 - 3;
            interpolated_Q[i*OUT_WIDTH] = symbol_Q_msb * 3 - 3;
            interpolated_Q[(i+1)*OUT_WIDTH-1] = symbol_Q_lsb * 3 - 3;
        end

        // Interpolation
        for (j = N-1; j > 0; j = j - 2) begin
            interpolated_I[(j*OUT_WIDTH) + OUT_WIDTH/2] = (interpolated_I[j*OUT_WIDTH] + interpolated_I[(j+1)*OUT_WIDTH-OUT_WIDTH/2]) / 2;
            interpolated_Q[(j*OUT_WIDTH) + OUT_WIDTH/2] = (interpolated_Q[j*OUT_WIDTH] + interpolated_Q[(j+1)*OUT_WIDTH-OUT_WIDTH/2]) / 2;
        end

        // Output arrangement
        I = {interpolated_I, interpolated_I[(N-1)*OUT_WIDTH:N*OUT_WIDTH-1], interpolated_I[(N-2)*OUT_WIDTH:N*OUT_WIDTH-1]};
        Q = {interpolated_Q, interpolated_Q[(N-1)*OUT_WIDTH:N*OUT_WIDTH-1], interpolated_Q[(N-2)*OUT_WIDTH:N*OUT_WIDTH-1]};
    end

endmodule
