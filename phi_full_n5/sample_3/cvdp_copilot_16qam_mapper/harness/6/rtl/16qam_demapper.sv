module qam16_demapper_interpolated #(
    parameter N = 4,
    parameter OUT_WIDTH = 4,
    parameter IN_WIDTH = 3
) (
    input logic signed [(IN_WIDTH-1)*N/2 + IN_WIDTH - 1] I,
    input logic signed [(IN_WIDTH-1)*N/2 + IN_WIDTH - 1] Q,
    output logic [N*OUT_WIDTH-1:0] bits,
    output logic error_flag
);

    // Local variables for intermediate calculations
    logic [IN_WIDTH-1:0] I_mapped[N/2], Q_mapped[N/2];
    logic [IN_WIDTH-1:0] interpolated_I[N/2], interpolated_Q[N/2];
    logic [IN_WIDTH-1:0] expected_I, expected_Q;
    logic [IN_WIDTH-1:0] error_detected;

    // Parsing input vectors into mapped and interpolated values
    for (integer i = 0; i < N/2; i++) begin
        I_mapped[i] = I[(i*IN_WIDTH + IN_WIDTH - 1):(i*IN_WIDTH)];
        Q_mapped[i] = Q[(i*IN_WIDTH + IN_WIDTH - 1):(i*IN_WIDTH)];
        interpolated_I[i] = I[(i*IN_WIDTH + IN_WIDTH/2 + IN_WIDTH - 1):(i*IN_WIDTH + IN_WIDTH/2)];
        interpolated_Q[i] = Q[(i*IN_WIDTH + IN_WIDTH/2 + IN_WIDTH - 1):(i*IN_WIDTH + IN_WIDTH/2)];
    end

    // Calculating expected values for error detection
    for (integer i = 0; i < N/2; i++) begin
        expected_I[i] = (I_mapped[i] + I_mapped[i+1]) >> IN_WIDTH;
        expected_Q[i] = (Q_mapped[i] + Q_mapped[i+1]) >> IN_WIDTH;
    end

    // Mapping I/Q components to bits and checking for errors
    integer j;
    for (j = 0; j < N; j++) begin
        error_detected = 0;
        // Calculate MSBs from I and LSBs from Q
        bits[(j*OUT_WIDTH)-1:0] = {(I_mapped[j/2] >> (IN_WIDTH-1)) | (Q_mapped[j/2] >> (IN_WIDTH-1)),
                                    (interpolated_I[j/2] >> (IN_WIDTH-1)) | (interpolated_Q[j/2] >> (IN_WIDTH-1))};

        // Error detection
        for (integer k = 0; k < N/2; k++) begin
            if (abs(interpolated_I[k] - expected_I[k]) > ERROR_THRESHOLD) begin
                error_detected = 1;
                break;
            end
            if (abs(interpolated_Q[k] - expected_Q[k]) > ERROR_THRESHOLD) begin
                error_detected = 1;
                break;
            end
        end
        if (error_detected) begin
            error_flag = 1;
            break;
        end
    end

endmodule
