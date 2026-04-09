module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,               // Asynchronous active-high signal to load custom time
    input wire [4:0] load_hours,    // Hours to load (0-23)
    input wire [5:0] load_minutes,  // Minutes to load (0-59)
    input wire [5:0] load_seconds,  // Seconds to load (0-59)
    output reg [5:0] seconds,      // Seconds counter (0-59)
    output reg [5:0] minutes,      // Minutes counter (0-59)
    output reg hour                // Hour counter
);

    localparam COUNTER_MAX = CLK_FREQ - 1;  // Calculate max counter value
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal

    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec_pulse <= 0;
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else begin
            counter <= counter + 1;
            one_sec_pulse <= 1'b0;
        end
    end

    // Load and countdown logic
    always @(posedge clk or posedge load or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (load) begin
            // Clamp load values to valid range
            load_hours <= (load_hours < 6'b100 ? load_hours : 6'b100);
            load_minutes <= (load_minutes < 6'b60 ? load_minutes : 6'b60);
            load_seconds <= (load_seconds < 6'b60 ? load_seconds : 6'b60);

            // Load the timer with specified values
            seconds <= load_seconds;
            minutes <= load_minutes;
            hour <= load_hours;
        end else if (start_stop) begin
            // Countdown logic
            if (counter == COUNTER_MAX) begin
                counter <= 0;
                one_sec_pulse <= 1'b1;
                // Decrement seconds, minutes, hours
                seconds <= seconds - 1'b1;
                if (seconds == 0) begin
                    seconds <= 6'b0;
                    minutes <= minutes - 1'b1;
                    if (minutes == 0) begin
                        minutes <= 6'b0;
                        hour <= hour - 1'b1;
                    end
                end
            end else begin
                // Ensure one_sec_pulse is cleared if paused
                one_sec_pulse <= 1'b0;
            end
        end
    end

endmodule
