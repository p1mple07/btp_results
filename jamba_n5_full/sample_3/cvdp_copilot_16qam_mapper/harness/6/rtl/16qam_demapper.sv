module qam16_demapper_interpolated #(
    parameter N = 4,
    OUT_WIDTH = 4,
    IN_WIDTH = 3
)(
    input logic [N+N/2-1:0] I,
    input logic [N+N/2-1:0] Q,
    output logic [OUT_WIDTH-1:0] bits,
    output logic error_flag
);

    localparam num_groups = (N + N/2) / 2;
    localparam total_bits = N * OUT_WIDTH;

    logic [OUT_WIDTH-1:0] demapped_bits;
    logic error_detected;

    // Iterate over each group
    for (int i = 0; i < num_groups; i++) begin: group_loop
        logic [IN_WIDTH-1:0] i_val = I[2*i];
        logic [IN_WIDTH-1:0] q_val = Q[2*i];

        // Compute interpolated value: average of i_val and i_val+1 (mod N?)
        // For simplicity, use midpoint.
        logic [IN_WIDTH-1:0] interp_val = (i_val + (i_val + 1)) / 2.to_logic();

        // Map I and Q to bits
        logic [OUT_WIDTH-1:0] mapped_i = convert_signed_to_4bit(i_val);
        logic [OUT_WIDTH-1:0] mapped_q = convert_signed_to_4bit(q_val);

        // Combine to get the demapped bits
        demapped_bits = mapped_i[OUT_WIDTH/2-1 : 0] << (OUT_WIDTH/2) | mapped_q[OUT_WIDTH/2-1 : 0];

        // Check error
        error_detected = interp_val != i_val; // if any deviation
        error_flag = error_detected;

        // Assign to outputs
        assign bits = demapped_bits;
        assign error_flag = error_detected;
    end

endmodule
