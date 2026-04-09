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

    localparam COUNTER_MAX = CLK_FREQ - 1;  // Calculate max counter value
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal

    // New ports
    input wire load;
    input wire load_hours;
    input wire load_minutes;
    input wire load_seconds;

    // Clamping functions
    function int clamp(int value, int min, int max) returns int;
        if (value < min) return min;
        if (value > max) return max;
        return value;
    endfunction

    // Initialize load_seconds, etc.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec_pulse <= 1'b0;
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            load_seconds <= 0;
            load_minutes <= 0;
            load_hours <= 0;
        end else begin
            if (load) begin
                load_seconds <= clamp(load_seconds, 0, 59);
                load_minutes <= clamp(load_minutes, 0, 59);
                load_hours <= clamp(load_hours, 0, 23);
            end
        end
    end

    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec_pulse <= 1'b0;
        end else begin
            if (start_stop) begin
                if (counter == COUNTER_MAX) begin
                    counter <= 0;
                    one_sec_pulse <= 1'b1;        // Generate a pulse every second
                end else begin
                    counter <= counter + 1;
                    one_sec_pulse <= 1'b0;
                end
            end else begin
                one_sec_pulse <= 1'b0;           // Ensure one_sec_pulse is cleared if paused
            end
        end
    end

    // Stopwatch logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop == 1 && hour == 0) begin
            if (seconds < 59) begin
                seconds <= seconds + 1'b1;
            end else begin
                seconds <= 6'b0;
                if (minutes < 59) begin
                    minutes <= minutes + 1'b1;
                end else begin
                    minutes <= 6'b0;
                    hour <= 1'b1;
                end
            end
        end
    end

endmodule
