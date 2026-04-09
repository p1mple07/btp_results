module qam16_demapper_interpolated(
    input  logic [IN_WIDTH-1:0] I,
    input  logic [IN_WIDTH-1:0] Q,
    input  logic N,
    output logic [OUT_WIDTH-1:0] bits,
    output logic error_flag
);

    localparam num_pairs = N / 2;
    localvar real_out, imag_out;
    localvar int expected_real, real_out_val;

    initial begin
        error_flag = 0;
        for (int i = 0; i < num_pairs; i++) begin
            // Compute expected real from averaged mapped samples
            expected_real = (I[2*i] + I[2*i+1]) / 2;
            real_out_val = (I[2*i] + I[2*i+1]) / 2;

            // Convert to 4-bit
            bits[4*i] = real_out_val >> 2;
            bits[4*i+1] = (real_out_val >> 1) & 3;
            bits[4*i+2] = (real_out_val >> 0) & 3;
            bits[4*i+3] = ((real_out_val << 1) & 7) >> 2;

            // Check for error
            if (abs(real_out_val - expected_real) > 1)
                error_flag = 1;
        end
    end

endmodule
