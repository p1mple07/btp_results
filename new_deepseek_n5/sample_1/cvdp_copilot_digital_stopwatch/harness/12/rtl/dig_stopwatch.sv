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
)
    output reg paused;            // Whether the timer is paused
    // Internal state variables
    reg [COUNTER_MAX+1:0] counter; // Counter for timing
    reg [1:0] seconds_state;      // State of seconds counter
    reg [2:0] minutes_state;      // State of minutes counter
    reg [3:0] hour_state;         // State of hour counter
    reg [6:0] current_time;       // Current time being displayed
)
    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Timer is reset to 00:00:00 immediately
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            current_time <= 6'b0;
            paused <= 0;
        else if (load) begin
            // Load new time and start countdown
            current_time <= [hour_state:2, minutes_state:1, seconds_state:0];
            seconds <= load_seconds;
            minutes <= load_minutes;
            hour <= load_hours;
            counter <= 0;
            paused <= 0;
        else if (start_stop) begin
            // If start/stop is asserted and not paused, decrement timer
            if (paused) begin
                // Resume countdown from current time
                counter <= current_time;
            else begin
                if (counter == COUNTER_MAX) begin
                    // Timer completes one second
                    counter <= 0;
                    seconds_state <= 1'b0;
                    minutes_state <= 1'b0;
                    hour_state <= 1'b0;
                else begin
                    // Decrement counter and update time state
                    counter <= counter + 1;
                    seconds_state <= seconds_state ^ 1;
                    if (seconds_state == 0) begin
                        seconds <= seconds + 1;
                        seconds_state <= 1'b0;
                    end else begin
                        minutes_state <= minutes_state ^ 1;
                        if (minutes_state == 0) begin
                            minutes <= minutes + 1;
                            minutes_state <= 1'b0;
                        end else begin
                            hour_state <= hour_state ^ 1;
                            if (hour_state == 0) begin
                                hour <= hour + 1;
                                hour_state <= 1'b0;
                            end
                        end
                    end
                end
            end
        end else begin
            // If start/stop is not asserted and not paused, timer remains stopped
            if (paused) begin
                // Do nothing
            end
        end
    end

    // Countdown logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            current_time <= 6'b0;
        end else if (paused) begin
            // If paused, hold current time
            current_time <= current_time;
        end else begin
            // Decrement time
            if (counter == 0) begin
                // Timer completed one second
                counter <= COUNTER_MAX;
                seconds_state <= 1'b0;
                minutes_state <= 1'b0;
                hour_state <= 1'b0;
            else begin
                // Decrement counter and update time state
                counter <= counter - 1;
                seconds_state <= seconds_state ^ 1;
                if (seconds_state == 1) begin
                    seconds <= seconds - 1;
                    seconds_state <= 1'b0;
                end else begin
                    minutes_state <= minutes_state ^ 1;
                    if (minutes_state == 1) begin
                        minutes <= minutes - 1;
                        minutes_state <= 1'b0;
                    end else begin
                        hour_state <= hour_state ^ 1;
                        if (hour_state == 1) begin
                            hour <= hour - 1;
                            hour_state <= 1'b0;
                        end
                    end
                end
            end
        end
    end

    // Handle underflow condition
    always @* begin
        if (seconds == 60 || minutes == 60 || hour == 24) begin
            // Roll back to 00:00:00
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            current_time <= 6'b0;
        end
    end
endmodule