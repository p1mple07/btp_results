module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input  wire         clk,                // Input clock (parameterized frequency)
    input  wire         reset,              // Reset signal (asynchronous active-high)
    input  wire         start_stop,         // Start/Stop control
    input  wire         load,               // Asynchronous active-high load signal
    input  wire [4:0]   load_hours,         // Hours to load (0 to 23)
    input  wire [5:0]   load_minutes,       // Minutes to load (0 to 59)
    input  wire [5:0]   load_seconds,       // Seconds to load (0 to 59)
    output reg  [5:0]   seconds,            // Seconds counter (0-59)
    output reg  [5:0]   minutes,            // Minutes counter (0-59)
    output reg  [4:0]   hour                // Hour counter (0-23)
);

    // Calculate max counter value based on CLK_FREQ
    localparam COUNTER_MAX = CLK_FREQ - 1;
    // Width of the clock divider counter based on CLK_FREQ
    reg [$clog2(COUNTER_MAX):0] counter;
    // One second pulse signal generated from the clock divider
    reg one_sec_pulse;

    //-------------------------------------------------------------------------
    // Clock divider: Generates a one-second pulse on posedge clk.
    // It only increments the counter if start_stop is asserted and load is deasserted.
    //-------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter    <= 0;
            one_sec_pulse <= 0;
        end else begin
            // Only count when countdown is active and not loading
            if (start_stop && !load) begin
                if (counter == COUNTER_MAX) begin
                    counter    <= 0;
                    one_sec_pulse <= 1'b1;  // Generate one second pulse
                end else begin
                    counter    <= counter + 1;
                    one_sec_pulse <= 1'b0;
                end
            end else begin
                one_sec_pulse <= 1'b0;  // Clear pulse if paused or loading
            end
        end
    end

    //-------------------------------------------------------------------------
    // Countdown logic: Updates the timer on one_sec_pulse or when load is asserted.
    // - On reset: Timer is set to 00:00:00.
    // - On load: Timer loads new values (with clamping to valid ranges).
    // - On one_sec_pulse: Timer decrements by one second, stopping at 00:00:00.
    //-------------------------------------------------------------------------
    always @(posedge clk or posedge reset or posedge load or posedge one_sec_pulse) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour    <= 5'b0;
        end else if (load) begin
            // Load new values with clamping:
            // Hours: clamp to max 23, Minutes & Seconds: clamp to max 59.
            seconds <= (load_seconds > 6'd59) ? 6'd59 : load_seconds;
            minutes <= (load_minutes > 6'd59) ? 6'd59 : load_minutes;
            hour    <= (load_hours  > 5'd23) ? 5'd23 : load_hours;
        end else if (one_sec_pulse) begin
            // Only decrement if the timer is not already at 00:00:00.
            if ( (hour == 5'b0) && (minutes == 6'b0) && (seconds == 6'b0) ) begin
                // Already at zero; hold state.
            end else begin
                if (seconds != 6'd0) begin
                    seconds <= seconds - 1;
                end else begin
                    // Underflow in seconds: roll over to 59 and decrement minutes.
                    seconds <= 6'd59;
                    if (minutes != 6'd0) begin
                        minutes <= minutes - 1;
                    end else begin
                        // Minutes underflow: roll over to 59 and decrement hour.
                        minutes <= 6'd59;
                        if (hour != 5'd0) begin
                            hour <= hour - 1;
                        end
                        // If hour is 0, the timer is at 00:00:00 and will hold.
                    end
                end
            end
        end
    end

endmodule