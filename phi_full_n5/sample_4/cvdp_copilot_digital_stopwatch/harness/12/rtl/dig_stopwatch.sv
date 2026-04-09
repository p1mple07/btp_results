module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,               // Asynchronous active-high signal to load time
    input wire [4:0] load_hours,    // Number of hours to load
    input wire [5:0] load_minutes,  // Number of minutes to load
    input wire [5:0] load_seconds,  // Number of seconds to load
    output reg [5:0] seconds,      // Seconds counter (0-59)
    output reg [5:0] minutes,      // Minutes counter (0-59)
    output reg hour                // Hour counter 
);

    localparam COUNTER_MAX = CLK_FREQ - 1;  // Calculate max counter value
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal

    // Load logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (load) begin
            // Default to maximum valid values if inputs exceed range
            seconds <= (load_seconds < 6'd60) ? load_seconds : 6'd59;
            minutes <= (load_minutes < 6'd60) ? load_minutes : 6'd59;
            hour <= (load_hours < 6'd24) ? load_hours : 6'd23;
        end
    end

    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec_pulse <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == COUNTER_MAX) begin
                one_sec_pulse <= 1'b1;        // Generate a pulse every second
            end
        end
    end

    // Stopwatch logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (start_stop == 1 && !load) begin
            if (seconds < 6'd0) begin
                // Handle underflow condition
                seconds <= 6'd59;
                minutes <= (seconds == 6'd59) ? 6'd0 : minutes - 1;
                hour <= (minutes == 6'd0) ? 6'd0 : hour - 1;
            end else begin
                seconds <= seconds - 1'b1;
                if (seconds == 6'd0) begin
                    seconds <= 6'd59;
                    minutes <= minutes - 1'b1;
                    if (minutes == 6'd0) begin
                        minutes <= 6'd59;
                        hour <= hour - 1'b1;
                    end
                end
            end
        end
    end

endmodule
