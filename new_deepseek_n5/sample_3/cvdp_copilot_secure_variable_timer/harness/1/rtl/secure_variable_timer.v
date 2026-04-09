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
    reg state;                  // State machine state
    reg [3:0] counter;          // Counter for the delay cycles
    reg [3:0] time_left;        // Time remaining for counting

    // State transitions
    always @(i_data_in, i_rst_n, i_ack, i_clk) begin
        if (i_rst_n) begin
            state = Idle;
            delay = 0;
            counter = 0;
            time_left = 0;
        end else if (state == Idle) begin
            if (i_data_in == 1101) begin
                state = Configure Delay;
                // Initialize time_left with delay value
                time_left = delay;
            end
        end else if (state == Configure Delay) begin
            // Read next 4 bits as delay
            delay = i_data_in;
            state = Counting;
        end else if (state == Counting) begin
            if (counter < 1000) begin
                time_left = time_left - 1;
                o_processing = 1;
                counter = counter + 1;
            else begin
                o_time_left = time_left;
                o_processing = 0;
                state = Done;
            end
        end else if (state == Done) begin
            // Wait for acknowledgment
            if (i_ack) begin
                state = Idle;
                o_completed = 1;
            end
        end
    end

    // Output assignments
    o_time_left = time_left;
    o_processing = (state == Counting);
    o_completed = (state == Done);
endmodule