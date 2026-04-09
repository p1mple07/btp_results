// rtl/fsm_seq_detector.sv
// Finite State Machine (FSM) sequence detector for the sequence 10110001

module fsm_seq_detector (
    input  bit         clk_in,    // 50% duty cycle clock
    input  logic       rst_in,    // asynchronous active-high reset
    input  logic       seq_in,    // serial input bit (0 or 1)
    output logic       seq_detected  // output pulse when sequence is detected
);

    // Define enumerated type for states S0 to S7 (3-bit representation)
    typedef enum logic [2:0] {
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100,
        S5 = 3'b101,
        S6 = 3'b110,
        S7 = 3'b111
    } state_t;

    state_t state_reg, next_state;
    logic seq_detected_w;

    // Combinational always block: Next state logic and detection pulse generation
    always_comb begin
        seq_detected_w = 1'b0;
        unique case (state_reg)
            S0: begin
                // Expecting first bit: 1
                if (seq_in == 1'b1)
                    next_state = S1;
                else
                    next_state = S0;
            end
            S1: begin
                // Matched "1"; expecting next bit: 0
                if (seq_in == 1'b0)
                    next_state = S2;
                else
                    // Overlap: new bit equals pattern[0] (1), so remain in S1
                    next_state = S1;
            end
            S2: begin
                // Matched "10"; expecting next bit: