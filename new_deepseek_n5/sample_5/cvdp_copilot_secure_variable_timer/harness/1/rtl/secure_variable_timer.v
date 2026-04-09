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
    reg state;                  // State machine state (Idle, Configure Delay, Counting, Done)
    reg [31:0] counter;         // Counter for the delay cycles
    reg [3:0] time_left;        // Remaining time in delay

    // Initialize state and registers
    always_comb begin
        state = Idle;
        delay = 0;
        counter = 0;
        time_left = 0;
    end

    // State machine logic
    case(state)
        Idle:
            // Look for '1101' pattern
            if (i_data_in & 0b1101)
                state = Configure Delay;
            // Else stay in Idle

        Configure Delay:
            // Read next 4 bits as delay
            delay = i_data_in[3:0];
            // Transition to Counting state
            state = Counting;

        Counting:
            // Start counting
            counter = counter + 1;
            o_processing = 1;
            
            // Update time_left
            time_left = delay;
            while (counter < 1000) begin
                time_left = time_left - 1;
                counter = counter + 1;
            end
            // Once counter reaches 1000, decrement time_left for remaining cycles
            while (counter > 1000) begin
                time_left = time_left - 1;
                counter = counter + 1;
            end
            o_time_left = time_left;

            // When counter reaches (delay + 1)*1000, transition to Done state
            state = Done;

        Done:
            // Wait for acknowledgment
            if (i_ack)
                state = Idle;
    endcase

endmodule