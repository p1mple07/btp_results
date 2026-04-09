module enhanced_fsm_signal_processor (
    input clock,
    input [1] rst_n,
    input [1] enable,
    input [1] clear,
    input [1] ack,
    input [5] vector_1,
    input [5] vector_2,
    input [5] vector_3,
    input [5] vector_4,
    input [5] vector_5,
    input [5] vector_6,
    output [1] ready,
    output [1] error,
    output [2] fsm_status,
    output [8] vector_1,
    output [8] vector_2,
    output [8] vector_3,
    output [8] vector_4
);

    // FSM state variables
    reg [1] state = 0; // IDLE = 00, PROCESS = 01, READY = 10, FAULT = 11
    reg [1] next_state;

    // Vector processing buffer
    reg [29:0] processed_vector;

    // Acknowledgment handling
    reg [1] ack_held = 0;

    // State transition table
    always @posedge clock begin
        case (state)
            0: // IDLE
                if (rst_n) next_state = 0;
                else if (enable) next_state = 1;
                else next_state = 0;
                // Assign outputs
                ready = 0;
                error = 0;
                fsm_status = 0b00;
                // Process vectors only in PROCESS state
                if (enable) begin
                    // Pack vectors into 30-bit bus
                    processed_vector = vector_1 << 24 | vector_2 << 19 | vector_3 << 14 | vector_4 << 9 | vector_5 << 4 | vector_6;
                    processed_vector |= (1 << 2); // Add two '1's at LSB
                    // Split into output vectors
                    vector_1 = (processed_vector >> 24) & 0b11111111;
                    vector_2 = (processed_vector >> 19) & 0b11111111;
                    vector_3 = (processed_vector >> 14) & 0b11111111;
                    vector_4 = (processed_vector >> 9) & 0b11111111;
                end
                state = next_state;
            1: // PROCESS
                if (i_fault) next_state = 3;
                else if (ack) next_state = 2;
                else next_state = 1;
                // Assign outputs
                ready = 0;
                error = 0;
                fsm_status = 0b01;
                // Vector outputs are already assigned from processed_vector
            2: // READY
                if (ack) next_state = 0;
                else if (clear && !i_fault) next_state = 3;
                else next_state = 2;
                // Assign outputs
                ready = 1;
                error = 0;
                fsm_status = 0b10;
            3: // FAULT
                if (clear && !i_fault) next_state = 0;
                else next_state = 3;
                // Assign outputs
                ready = 0;
                error = 1;
                fsm_status = 0b11;
                // Reset outputs and clear fault
                vector_1 = 0;
                vector_2 = 0;
                vector_3 = 0;
                vector_4 = 0;
        endcase
    end

    // Acknowledgment handling
    always @posedge clock begin
        if (clear) begin
            ack_held = 1;
        else if (ack && !clear) ack_held = 0;
        else ack_held = ack;
    end