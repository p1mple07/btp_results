module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Internal registers
    reg [3:0] delay;            // Holds the 4-bit delay value
    reg state;                  // State machine state: IDLE, CONFIGURE_DELAY, COUNTING, DONE

    // FSM for pattern detection
    reg [3:0] data_reg = 0;    // Shift register for data input
    reg pattern_match = 0;      // Flag for detecting '1101' pattern

    // Counters and timing
    reg [3:0] counter = 0;      // Counter for delay cycles
    reg [3:0] time_left;        // Remaining time output

    // Acknowledgment handling
    reg ack_received = 0;       // Flag for acknowledged completion

    // State transitions
    always @(i_clk) begin
        if (i_rst_n) begin
            state = IDLE;
            data_reg = 0;
            pattern_match = 0;
            time_left = 0;
            ack_received = 0;
        end else begin
            case (state)
                IDLE: begin
                    // Detect '1101' pattern
                    data_reg = (data_reg << 1) | (i_data_in & 1);
                    if (data_reg == 13) begin // '1101' pattern detected
                        state = CONFIGURE_DELAY;
                        data_reg = 0;
                    end
                end

                CONFIGURE_DELAY: begin
                    // Read delay value from next 4 bits
                    delay = i_data_in;
                    state = COUNTING;
                end

                COUNTING: begin
                    // Count delay + 1000 cycles
                    counter = 0;
                    time_left = delay + 1000;
                    o_time_left = time_left;
                    o_processing = 1;
                end

                DONE: begin
                    // Assert completion and wait for ack
                    o_completed = 1;
                    ack_received = 1;
                    o_time_left = 0;
                    o_processing = 0;
                end
            endcase
        end
    end

    // Update outputs based on state
    always @(i_clk) begin
        if (state == COUNTING) begin
            counter = counter + 1;
            time_left = time_left - 1;
            o_time_left = time_left;
        end else if (state == DONE) begin
            o_completed = ack_received;
        end
    end
endmodule