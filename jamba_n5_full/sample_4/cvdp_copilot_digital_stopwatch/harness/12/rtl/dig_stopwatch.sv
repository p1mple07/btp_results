module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    output reg [5:0] seconds,      // Seconds counter (0-59)
    output reg [5:0] minutes,      // Minutes counter (0-59)
    output reg hour                // Hour counter 
);

    localparam COUNTER_MAX = CLK_FREQ - 1;  // Max counter value for 1Hz
    reg [$clog2(COUNTER_MAX):0] counter;
    reg one_sec_pulse;
    reg load_event;
    reg load_h_valid, load_m_valid, load_s_valid;

    // Counters for loading? Not needed.

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0000000;
            minutes <= 6'b0000000;
            hour <= 1'b0;
            load_event <= 0;
            load_h_valid <= load_m_valid <= load_s_valid <= 1'b0;
        end else begin
            if (start_stop) begin
                if (load_event) begin
                    seconds <= 6'b0000000;
                    minutes <= 6'b0000000;
                    hour <= 1'b0;
                end
                load_event <= 1'b0;
            end else begin
                load_event <= 1'b1;
            end
        end
    end

    // Check load conditions
    assign load_event = (load_hours != 1'b0 || load_minutes != 1'b0 || load_seconds != 1'b0);

    always @(posedge clk or posedge load_event) begin
        if (load_event) begin
            if (load_hours != 0) seconds = 6'b0;
            else if (load_minutes != 0) minutes = 6'b0;
            else if (load_seconds != 0) hour = 1'b0;

            // Ensure values are within range
            if (seconds > 59) seconds = 59;
            if (minutes > 59) minutes = 59;
            if (hour > 23) hour = 23;
        end
    end

    // Pause and resume logic
    assign one_sec_pulse = start_stop && !load_event;

    // Counter generation: decrement when not paused
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 6'd0;
            one_sec_pulse <= 1'b0;
        end else begin
            if (one_sec_pulse) begin
                if (counter >= COUNTER_MAX) begin
                    counter <= 6'd0;
                    one_sec_pulse <= 1'b1;
                end else begin
                    counter <= counter - 1;
                    one_sec_pulse <= 1'b0;
                end
            end else begin
                one_sec_pulse <= 1'b0;
            end
        end
    end

    // Stop at zero
    assign seconds = 6'b0;
    assign minutes = 6'b0;
    assign hour = 1'b0;

endmodule
