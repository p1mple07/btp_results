module secure_variable_timer (
    input wire i_clk,           // Clock signal (rising-edge triggered)
    input wire i_rst_n,         // Active-low synchronous reset signal
    input wire i_data_in,       // Serial data input
    output reg [3:0] o_time_left, // 4-bit output showing remaining time during counting phase
    output reg o_processing,    // Asserted high when the timer is actively counting
    output reg o_completed,     // Asserted high when the timer completes its delay
    input wire i_ack            // Acknowledgment signal to reset after completion
);

    // Internal state variable
    reg state;                  // 0:Idle, 1:Configure Delay, 2:Counting, 3:Done

    // Internal registers
    reg [3:0] delay;            // Holds the 4-bit delay value

    // State transitions
    always @(i_rst_n, i_data_in, o_processing, o_completed) begin
        case(state)
            0: // Idle state
                if (i_rst_n) begin
                    state = 0;
                    // Reset all states on reset
                    // Begin searching for 1101 pattern
                    data_reg = 0;
                    state = 1;
                end
                // If 1101 is detected, transition to Configure Delay state
                if (i_data_in) begin
                    data_reg = 3;
                    state = 1;
                end
            1: // Configure Delay state
                if (i_rst_n) begin
                    state = 0;
                end
                // Read next 4 bits as delay value
                delay = data_reg;
                data_reg = 0;
                state = 2;
            2: // Counting state
                if (i_rst_n) begin
                    state = 0;
                end
                o_processing = 1;
                // Count for (delay + 1) * 1000 clock cycles
                // o_time_left starts at delay and decrements by 1 every 1000 cycles
                o_time_left = delay;
                data_reg = (data_reg + 1) % 16;
                state = 2;
                o_time_left = o_time_left - 1;
                if (data_reg == 15) begin
                    o_completed = 1;
                    state = 3;
                end
            3: // Done state
                if (i_ack) begin
                    state = 0;
                end
        endcase
    end

    // Initializations
    initial begin
        state = 0;
        data_reg = 0;
    end

endmodule