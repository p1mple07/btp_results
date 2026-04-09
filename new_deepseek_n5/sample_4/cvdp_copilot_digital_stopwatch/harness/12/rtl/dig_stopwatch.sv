module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,              // Load signal
    input wire [4:0] load_hours,   // Load hours
    input wire [5:0] load_minutes, // Load minutes
    input wire [5:0] load_seconds, // Load seconds
    output reg [5:0] seconds,      // Seconds counter (0-59)
    output reg [5:5] minutes,     // Minutes counter (0-59)
    output reg hour                // Hour counter 
);

    localparam COUNTER_MAX = CLK_FREQ - 1;  // Calculate max counter value
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal

    // Load handling
    always @posedge load or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop) begin
            if (counter == COUNTER_MAX) begin
                counter <= 0;
                one_sec_pulse <= 1'b1;        // Generate a pulse every second
            end else begin
                counter <= counter - 1;
                one_sec_pulse <= 1'b0;
            end
        end else begin
            one_sec_pulse <= 1'b0;           // Ensure one_sec_pulse is cleared if paused
        end
    end

    // Stopwatch logic
    always @posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop && !load) begin
            if (counter == 0) begin
                seconds <= 6'b0;
                minutes <= 6'b0;
                hour <= 1'b0;
            end else begin
                counter <= counter - 1;
            end
        end else if (load) begin
            // Load new time
            if (load_hours >= 24) load_hours <= 23;
            if (load_minutes >= 60) load_minutes <= 59;
            if (load_seconds >= 60) load_seconds <= 59;
            seconds <= load_seconds;
            minutes <= load_minutes;
            hour <= load_hours;
        end
    end

endmodule