module dig_stopwatch #(
    parameter CLK_FREQ = 50000000
)(
    input wire clk,
    input wire reset,
    input wire start_stop,
    input wire load,
    input wire [4:0] load_hours,
    input wire [5:0] load_minutes,
    input wire [5:0] load_seconds,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hour
);

    // Clamp loaded values to valid ranges:
    // Hours: 0 to 23, Minutes: 0 to 59, Seconds: 0 to 59.
    wire [4:0] clamped_hours = (load_hours > 5'd23) ? 5'd23 : load_hours;
    wire [5:0] clamped_minutes = (load_minutes > 6'd59) ? 6'd59 : load_minutes;
    wire [5:0] clamped_seconds = (load_seconds > 6'd59) ? 6'd59 : load_seconds;

    // Clock divider to generate a one-second pulse from the parameterized clock.
    localparam COUNTER_MAX = CLK_FREQ - 1;
    reg [$clog2(COUNTER_MAX):0] counter;
    reg one_sec_pulse;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            one_sec_pulse <= 1'b0;
        end else begin
            if (start_stop) begin
                if (counter == COUNTER_MAX) begin
                    counter <= 0;
                    one_sec_pulse <= 1'b1;
                end else begin
                    counter <= counter + 1;
                    one_sec_pulse <= 1'b0;
                end
            end else begin
                one_sec_pulse <= 1'b0;
            end
        end
    end

    // Immediate load: when 'load' is asserted, update the timer registers with the clamped values.
    // This block ensures that new values are loaded on the same clock cycle.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour    <= 5'b0;
        end else if (load) begin
            seconds <= clamped_seconds;
            minutes <= clamped_minutes;
            hour    <= clamped_hours;
        end
    end

    // Countdown logic: decrement the timer once per one-second pulse.
    // Countdown only occurs when 'start_stop' is asserted and 'load' is deasserted.
    // The timer stops decrementing when it reaches 00:00:00.
    always @(posedge one_sec_pulse or posedge reset) begin
        if (reset) begin
            seconds <= 6'b0;
            minutes <= 6'b0;
            hour    <= 5'b0;
        end else if (!load && start_stop) begin
            // Only perform countdown if not already at zero.
            if ((seconds != 6'd0) || (minutes != 6'd0) || (hour != 5'd0)) begin
                if (seconds != 6'd0) begin
                    seconds <= seconds - 1;
                end else if (minutes != 6'd0) begin
                    seconds <= 6'd59;
                    minutes <= minutes - 1;
                end else if (hour != 5'd0) begin
                    seconds <= 6'd59;
                    minutes <= 6'd59;
                    hour    <= hour - 1;
                end
            end
        end
    end

endmodule