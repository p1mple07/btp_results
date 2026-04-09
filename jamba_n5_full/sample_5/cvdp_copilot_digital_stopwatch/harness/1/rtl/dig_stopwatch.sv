module dig_stopwatch (
    input CLK_FREQ,
    input clk,
    input reset,
    input start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    localparam CLOCK_CYCLE = 1 / CLK_FREQ; // number of cycles per second

    always @(posedge clk or reset) begin
        if (!reset) begin
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end else if (start_stop) begin
            if (seconds == CLK_FREQ) begin
                seconds <= 0;
                minutes <= minutes + 1;
                if (minutes == CLK_FREQ)
                    minutes <= 0;
                    hour <= hour + 1;
            end
        end
    end

endmodule
