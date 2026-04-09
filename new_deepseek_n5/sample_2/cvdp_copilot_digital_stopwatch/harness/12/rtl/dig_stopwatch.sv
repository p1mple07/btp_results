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
    output reg [8:7] hours        // Hour counter 
);

    // Clamp values to valid ranges
    localparam MIN_HOURS = 0, MAX_HOURS = 23;
    localparam MIN MINUTES = 0, MAX MINUTES = 59;
    localparam MIN SECONDS = 0, MAX SECONDS = 59;
    
    // Load values if load is asserted
    if (load) begin
        hours <= [8:7] {MAX_HOURS', MAX_MINUTES', MAX SECONDS'};  // Reset to max values
        seconds <= MAX SECONDS;
        minutes <= MAX MINUTES;
    end else begin
        // Initialize to 00:00:00 upon reset
        if (reset) begin
            hours <= [8:7] 0;
            minutes <= 0;
            seconds <= 0;
        end else begin
            // Countdown logic
            always @(posedge clk or posedge reset) begin
                if (start_stop) begin
                    if (load) begin
                        // Load new values
                        hours <= [8:7] $cast unsigned (load_hours);
                        minutes <= $cast unsigned (load_minutes);
                        seconds <= $cast unsigned (load_seconds);
                        // Ensure values are within valid ranges
                        if (hours > MAX_HOURS) hours <= MAX_HOURS;
                        if (minutes > MAX MINUTES) minutes <= MAX MINUTES;
                        if (seconds > MAX SECONDS) seconds <= MAX SECONDS;
                    end else begin
                        // Decrement timer
                        if (seconds > 0) begin
                            seconds <= seconds - 1;
                        end else begin
                            seconds <= MAX SECONDS;
                            if (minutes > 0) begin
                                minutes <= minutes - 1;
                            end else begin
                                minutes <= MAX MINUTES;
                                if (hours > 0) begin
                                    hours <= hours - 1;
                                end else begin
                                    hours <= MAX_HOURS;
                                end
                            end
                        end
                    end
                end else begin
                    // Pause timer
                    one_sec_pulse <= 0;
                end
            end
        end
    end
endmodule