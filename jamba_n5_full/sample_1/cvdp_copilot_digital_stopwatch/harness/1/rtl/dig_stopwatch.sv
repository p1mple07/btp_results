module dig_stopwatch #(
    parameter CLK_FREQ = 50000000
) (
    input  wire clk,
    input  wire reset,
    input  wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    localparam int SECONDS_PER_HOUR = 3600;
    localparam int SECONDS_PER_MINUTE = 60;

    reg [5:0] counter;
    reg [31:0] time;

    initial begin
        counter = 0;
        time = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            counter = 0;
            time = 0;
            seconds = 0;
            minutes = 0;
            hour = 0;
        end else if (!reset) begin
            return;
        end

        if (start_stop) begin
            if (counter == 0) begin
                seconds = 0;
                minutes = 0;
                hour = 0;
            end else begin
                seconds++;
                if (seconds == SECONDS_PER_MINUTE) begin
                    seconds = 0;
                    minutes++;
                end
                if (minutes == SECONDS_PER_HOUR) begin
                    minutes = 0;
                    hour++;
                end
            end
        end

        if (seconds == 59 && minutes == 59 && hour == 59) begin
            hour = 1;
            seconds = 0;
            minutes = 0;
        end
    end

    assign seconds = seconds % 60;
    assign minutes = minutes % 60;
    assign hour = hour;

endmodule
