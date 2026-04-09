module dig_stopwatch (#(size: int) clk_freq=50000000, reset=0, start_stop=0, seconds=8, minutes=8, hour=8));
    localparam int SECONDS_PER_SECOND = 1;
    localparam int MINUTES_PER_SECOND = 60;

    // Counters
    reg [5:0] seconds_cnt;
    reg [5:0] minutes_cnt;
    reg [5:0] hour_cnt;

    // Outputs
    output reg [5:0] seconds;
    output reg [5:0] minutes;
    output reg hour;

    // Pulse flag
    reg pulse;

    // State machine for start/stop
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            seconds_cnt <= 0;
            minutes_cnt <= 0;
            hour_cnt <= 0;
            pulse <= 0;
            return;
        end

        if (start_stop == 1) begin
            if (counter == 0) begin
                started = 1;
            end
        end else if (start_stop == 0) begin
            started = 0;
        end
    end

    always @(posedge clk) begin
        if (started) begin
            if (counter == CLK_FREQ) begin
                pulse = 1;
                counter = 0;
            end else pulse = 0;

            if (seconds_cnt < 59) begin
                seconds_cnt <= seconds_cnt + 1;
            end else if (minutes_cnt < 59) begin
                minutes_cnt <= minutes_cnt + 1;
                seconds_cnt <= seconds_cnt + 1;
            end else begin
                hour_cnt <= hour_cnt + 1;
                minutes_cnt <= 0;
            end
        end
    end

    assign seconds = seconds_cnt;
    assign minutes = minutes_cnt;
    assign hour = hour_cnt;

endmodule
