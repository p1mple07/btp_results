module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input  wire         clk,
    input  wire         reset,
    input  wire         start_stop,
    input  wire         load,
    input  wire [4:0]   load_hours,    // Valid range: 0 to 23 (inclusive)
    input  wire [5:0]   load_minutes,  // Valid range: 0 to 59 (inclusive)
    input  wire [5:0]   load_seconds,  // Valid range: 0 to 59 (inclusive)
    output reg  [5:0]   seconds,       // Seconds counter (0-59)
    output reg  [5:0]   minutes,       // Minutes counter (0-59)
    output reg  [4:0]   hour           // Hour counter (0-23)
);

    // Maximum value for the clock divider counter based on CLK_FREQ
    localparam COUNTER_MAX = CLK_FREQ - 1;
    // Clock divider counter width based on CLK_FREQ
    reg [$clog2(COUNTER_MAX):0] counter;
    // One second pulse signal generated from the clock divider
    reg one_sec_pulse;

    // Clock divider: Generates a 1 Hz pulse from the parameterized clock.
    // Pauses counting (retains progress) when start_stop is deasserted.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter      <= 0;
            one_sec_pulse<= 1'b0;
        end else begin
            if (start_stop) begin
                if (counter == COUNTER_MAX) begin
                    counter      <= 0;
                    one_sec_pulse<= 1'b1;  // Generate a pulse every second
                end else begin
                    counter      <= counter + 1;
                    one_sec_pulse<= 1'b0;
                end
            end else begin
                one_sec_pulse<= 1'b0;  // Pause: do not update counter when paused
            end
        end
    end

    // Countdown logic: Operates on the rising edge of the one_sec_pulse or reset.
    // When reset is high, timer is set to 00:00:00.
    // When load is asserted, timer loads new values (with clamping) immediately.
    // When load is deasserted and start_stop is asserted, timer decrements by one second.
    // If any time unit is already at 0, underflow is prevented and timer holds at 00:00:00.
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour    <= 5'b0;
        end else if (load) begin
            // Load new time values with range clamping.
            if (load_hours >= 24)
                hour    <= 5'd23;
            else
                hour    <= load_hours;
            
            if (load_minutes >= 60)
                minutes <= 6'd59;
            else
                minutes <= load_minutes;
            
            if (load_seconds >= 60)
                seconds <= 6'd59;
            else
                seconds <= load_seconds;
        end else if (start_stop) begin
            // Only perform countdown if not at 00:00:00.
            if ((hour != 0) || (minutes != 0) || (seconds != 0)) begin
                if (seconds != 0)
                    seconds <= seconds - 1;
                else if (minutes != 0) begin
                    minutes <= minutes - 1;
                    seconds <= 6'd59;
                end else if (hour != 0) begin
                    hour    <= hour - 1;
                    minutes <= 6'd59;
                    seconds <= 6'd59;
                end
            end
            // If already at 00:00:00, do nothing.
        end
    end

endmodule