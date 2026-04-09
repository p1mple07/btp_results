module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,               // Asynchronous active-high signal to load specific time values
    input wire [4:0] load_hours,    // Hours to load, valid range: 0-23
    input wire [5:0] load_minutes,  // Minutes to load, valid range: 0-59
    input wire [5:0] load_seconds,  // Seconds to load, valid range: 0-59
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
            if (load) begin
                // Clamp values to valid range
                load_hours <= $clog2(load_hours) <= 4'b1111 ? 4'b1111 : load_hours;
                load_minutes <= $clog2(load_minutes) <= 6'b1111 ? 6'b1111 : load_minutes;
                load_seconds <= $clog2(load_seconds) <= 6'b1111 ? 6'b1111 : load_seconds;
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
    end

    // Stopwatch logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop == 1) begin
            // Load values if load signal is high
            if (load) begin
                seconds <= load_seconds;
                minutes <= load_minutes;
                hour <= load_hours;
            end
            // Countdown
            else begin
                if (seconds < 6'b000001) begin
                    seconds <= seconds + 6'b000001;
                end else begin
                    seconds <= 6'b000000;
                    if (minutes < 6'b000001) begin
                        minutes <= minutes + 6'b000001;
                    end else begin
                        minutes <= 6'b000000;
                        if (hour < 6'b000001) begin
                            hour <= hour + 6'b000001;
                        end else begin
                            hour <= 6'b000000;
                        end
                    end
                end
            end
        end
    end

endmodule
