module cvdp_prbs_gen (
    input clock,
    input rst,
    input [WIDTH-1:0] data_in,
    output [WIDTH-1:0] data_out
);

    // State to track the operating mode
    reg current_mode = CHECK_MODE;

    // LFSR state
    reg [POLY_LENGTH-1:0] lfsr_reg = (1 << POLY_LENGTH) - 1;

    // Feedback computation
    reg feedback_bit;
    reg [POLY_TAP[0]-1:0] taps = POLY_TAP;

    always @posedge clock begin
        if (rst) begin
            // Initialize to all ones
            lfsr_reg = (1 << POLY_LENGTH) - 1;
            data_out = (1 << WIDTH) - 1;
        else begin
            // Compute feedback bit
            feedback_bit = 0;
            for (int i = 0; i < taps.length; i++) begin
                feedback_bit ^= (lfsr_reg >> taps[i]) & 1;
            end
            feedback_bit = feedback_bit ^ ((lfsr_reg >> POLY_LENGTH) & 1);

            // Shift register and insert new bit
            lfsr_reg = (lfsr_reg >> 1);
            lfsr_reg = lfsr_reg | feedback_bit;

            // Generate data_out based on mode
            if (current_mode == 0) begin // Generator mode
                data_out = lfsr_reg;
            else begin // Checker mode
                // Generate expected PRBS bit
                reg [WIDTH-1:0] expected_prbs;
                expected_prbs = lfsr_reg;
                data_out = expected_prbs ^ data_in;
            end
        end
    end

    // Reset all registers on reset
    always @posedge clock begin
        if (rst) begin
            lfsr_reg = (1 << POLY_LENGTH) - 1;
            data_out = (1 << WIDTH) - 1;
        end
    end

endmodule