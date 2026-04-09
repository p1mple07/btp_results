module cvdp_prbs_gen(
    parameter CHECK_MODE = 0,
    parameter POLY_LENGTH = 31,
    parameter POLY_TAP = 3,
    parameter WIDTH = 16
);

    // State to manage mode transitions
    enum state_state = State(0 => "IDLE", 1 => "GENERATE", 2 => "CHECK");
    reg state_state = State(0);

    // PRBS registers
    reg prbs_reg = (1 << POLY_LENGTH) - 1; // Initialize to all ones

    // Feedback computation
    reg feedback = 0;
    always @* begin
        if (state_state == State(0)) {
            // During IDLE, initialize PRBS and start generation
            prbs_reg = (1 << POLY_LENGTH) - 1;
        }
    end

    // Compute feedback bit
    always @* begin
        if (state_state == State(1)) {
            // Compute feedback by XORing taps
            feedback = 0;
            for (int i = 0; i < size(POLY_TAP); i++) {
                feedback ^= (prbs_reg >> (POLY_LENGTH - 1 - POLY_TAP[i])) & 1;
            }
            // Shift register and insert feedback bit
            prbs_reg = (prbs_reg >> 1) | feedback;
        }
    end

    // Outputs
    wire [WIDTH-1:0] data_out;

    // State transition
    always @* begin
        if (rst) begin
            state_state = State(0);
            prbs_reg = (1 << POLY_LENGTH) - 1;
        end else if (state_state == State(1)) begin
            if (CHECK_MODE == 0) {
                // Generator mode: continue generating PRBS
                // No action needed, prbs_reg is already updated
            } else {
                // Checker mode: generate expected PRBS and compare with data_in
                // Generate expected bit
                feedback = 0;
                for (int i = 0; i < size(POLY_TAP); i++) {
                    feedback ^= (prbs_reg >> (POLY_LENGTH - 1 - POLY_TAP[i])) & 1;
                }
                // Compare with data_in
                data_out = 0;
                for (int i = 0; i < WIDTH; i++) {
                    data_out[i] = (data_in[i] ^ ((prbs_reg >> (WIDTH - 1 - i)) & 1));
                }
            }
        end
    end

    // Ensure data_out is properly set in all cases
    data_out = 0;
    for (int i = 0; i < WIDTH; i++) {
        if (state_state == State(1) && CHECK_MODE == 1) {
            data_out[i] = (data_in[i] ^ ((prbs_reg >> (WIDTH - 1 - i)) & 1));
        }
    }
endmodule