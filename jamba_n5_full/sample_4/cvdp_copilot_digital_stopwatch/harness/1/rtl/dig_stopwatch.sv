module dig_stopwatch #(
    parameter CLK_FREQ = 50000000
)(
    input CLK_FREQ,
    input clk,
    input reset,
    input start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    localparam CLK_CYCLES_PER_SECOND = CLK_FREQ;
    localvar int clk_count;

    initial begin
        clk_count = 0;
    end

    always @(posedge clk) begin
        if (!reset) begin
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end else if (!start_stop) begin
            // Pause the timer
        end else begin
            if (clk_count == CLK_CYCLES_PER_SECOND) begin
                // One second has elapsed
                seconds = 0;
                minutes = 0;
                hour = 0;
                clk_count = 0;
            end else begin
                clk_count++;
            end
        end
    end

    assign seconds = seconds % 60;
    assign minutes = minutes % 60;
    assign hour = hour;

endmodule
