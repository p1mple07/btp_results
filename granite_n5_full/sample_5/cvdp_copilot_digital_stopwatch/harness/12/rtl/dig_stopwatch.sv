module dig_stopwatch #(
    parameter CLK_FREQ = 50_000_000
) (
    input wire clk,
    input wire reset,
    input wire start_stop,
    input wire load,
    input wire [4:0] load_hours,
    input wire [5:0] load_minutes,
    input wire [5:0] load_seconds,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg [4:0] hours
);

// Constants and parameters
localparam COUNTER_MAX = CLK_FREQ - 1;

// Internal signals and registers
reg [$clog2(COUNTER_MAX):0] counter;
reg one_sec_pulse;
reg [4:0] hours;
reg [5:0] minutes;
reg [5:0] seconds;

always @ (posedge clk) begin
    case (state)
        STATE_INIT: begin
            hours = 6'b00;
            minutes = 6'b00;
            seconds = 6'b00;
            state = STATE_COUNTDOWN;
        end

        STATE_COUNTDOWN: begin
            if (reset) begin
                hours = 6'b00;
                minutes = 6'b00;
                seconds = 6'b00;
            end else if (minutes > 0) begin
                minutes = minutes - 1;
                seconds = 6'b00;
            end else if (seconds > 0) begin
                seconds = seconds - 1;
                minutes = minutes;
            end else begin
                minutes = 6'b00;
                seconds = 6'b00;
            end
        end

        STATE_PAUSE: begin
            minutes = 6'b00;
            seconds = 6'b00;
        end
    endcase

endmodule