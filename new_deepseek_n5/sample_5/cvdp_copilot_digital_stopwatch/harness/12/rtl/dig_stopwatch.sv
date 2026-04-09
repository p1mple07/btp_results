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

    // Local constants
    localparam COUNTER_MAX = (1 << (LOG2(CLOCK_FREQ - 1))) - 1;
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal

    // Load values and clamp to valid ranges
    if (load) begin
        hours = load_hours & 0x1F;
        minutes = load_minutes & 0x1F;
        seconds = load_seconds & 0x1F;
        // Set all counters to 00:00:00
        hour = 0;
        minutes = 0;
        seconds = 0;
        // Ensure one_sec_pulse is cleared
        one_sec_pulse = 0;
    end else if (start_stop) begin
        if (counter == COUNTER_MAX) begin
            counter = 0;
            one_sec_pulse = 1;
        else begin
            counter = counter + 1;
            one_sec_pulse = 0;
        end
    end else begin
        one_sec_pulse = 0;
    end

    // Countdown logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            hour = 0;
            minutes = 0;
            seconds = 0;
        end else if (start_stop) begin
            if (seconds > 0) begin
                seconds = seconds - 1;
            end else if (minutes > 0) begin
                minutes = minutes - 1;
                seconds = 60;
            end else if (hours > 0) begin
                hours = hours - 1;
                minutes = 60;
                seconds = 60;
            end else begin
                // Timer completed countdown
                hour = 0;
                minutes = 0;
                seconds = 0;
            end
        end
    end

    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter = 0;
            one_sec_pulse = 0;
        end else if (start_stop || load) begin
            if (counter == COUNTER_MAX) begin
                counter = 0;
                one_sec_pulse = 0;
            else begin
                counter = counter + 1;
                one_sec_pulse = 0;
            end
        end else begin
            one_sec_pulse = 0;
        end
    end

    // Cleanup on reset
    always @* begin
        if (reset) begin
            // Cleanup all counters
            hour = 0;
            minutes = 0;
            seconds = 0;
        end
    end