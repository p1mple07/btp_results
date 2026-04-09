module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,               // Asynchronous load signal
    input wire [4:0] load_hours,    // Load hours with default 0
    input wire [5:0] load_minutes,  // Load minutes with default 0
    input wire [5:0] load_seconds,  // Load seconds with default 0
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
                // Load new time values
                if (load_hours > 23) load_hours <= 23;
                if (load_minutes > 59) load_minutes <= 59;
                if (load_seconds > 59) load_seconds <= 59;
                seconds <= load_seconds;
                minutes <= load_minutes;
                hour <= load_hours;
            end else begin
                // Countdown logic
                if (start_stop) begin
                    if (hour == 0) begin
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
                end else begin
                    // Hold current state
                    seconds <= seconds;
                    minutes <= minutes;
                    hour <= hour;
                end
            end
        end
    end

endmodule
