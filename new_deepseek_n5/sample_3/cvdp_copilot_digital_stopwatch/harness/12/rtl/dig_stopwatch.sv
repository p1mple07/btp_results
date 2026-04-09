module dig_stopwatch #(
    parameter CLK_FREQ = 50000000  // Default clock frequency is 50 MHz
)(
    input wire clk,                // Input clock (parameterized frequency)
    input wire reset,              // Reset signal
    input wire start_stop,         // Start/Stop control
    input wire load,              // Load signal
    input wire [4:0] load_hours,   // Load hours (0-23)
    input wire [5:0] load_minutes, // Load minutes (0-59)
    input wire [5:0] load_seconds, // Load seconds (0-59)
    output reg [5:0] seconds,      // Seconds counter (0-59)
    output reg [5:5] minutes,     // Minutes counter (0-59)
    output reg hour                // Hour counter
)
{
    localparam COUNTER_MAX = CLK_FREQ - 1;  // Calculate max counter value
    reg [$clog2(COUNTER_MAX):0] counter;    // Clock divider counter width based on CLK_FREQ
    reg one_sec_pulse;                      // One second pulse signal
    reg counter_dec;                       // Counter for countdown
    reg [4:0] current_time;                // Current time being displayed
    reg counter_paused;                    // Whether counter is paused
};

    // Clock divider to create a 1 Hz clock pulse from parameterized frequency
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_time <= 000000;
            counter <= 0;
            one_sec_pulse <= 0;
            counter_paused <= 0;
        end else if (start_stop) begin
            if (load) begin
                current_time <= load_hload_mload_s;
                counter <= 0;
                one_sec_pulse <= 1'b1;
                counter_paused <= 0;
            end else if (counter_paused) begin
                // Resume countdown
                if (counter == 0) begin
                    counter <= COUNTER_MAX;
                    one_sec_pulse <= 0;
                end else begin
                    counter <= counter - 1;
                    one_sec_pulse <= 1'b0;
                end
            end else begin
                one_sec_pulse <= 1'b0;
            end
        end else if (load) begin
            // Load new time
            current_time <= load_hload_mload_s;
            counter <= 0;
            one_sec_pulse <= 1'b1;
            counter_paused <= 0;
        end else begin
            // Pause countdown
            counter_paused <= 1;
            one_sec_pulse <= 0;
        end
    end

    // Countdown logic
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
            counter <= 0;
        end else if (counter_paused) begin
            // Resume countdown
            if (counter == 0) begin
                counter <= COUNTER_MAX;
                one_sec_pulse <= 0;
            end else begin
                counter <= counter - 1;
                one_sec_pulse <= 1'b0;
            end
        end else if (start_stop) begin
            if (counter == COUNTER_MAX) begin
                counter <= 0;
                one_sec_pulse <= 1'b1;
            end else begin
                counter <= counter + 1;
                one_sec_pulse <= 1'b0;
            end
        end
    end

    // Display logic
    always begin
        if (counter == 0) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour <= 1'b0;
        end else if (counter > 0) begin
            if (counter < 60) begin
                seconds <= counter;
            end else if (counter < 3600) begin
                minutes <= (counter / 60);
                counter <= counter % 60;
                seconds <= counter;
            end else begin
                hour <= (counter / 3600);
                minutes <= (counter / 60) % 60;
                seconds <= (counter / 60) % 60;
                counter <= 0;
            end
        end
    end
}