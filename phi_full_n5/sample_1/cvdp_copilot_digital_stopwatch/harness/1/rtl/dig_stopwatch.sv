module dig_stopwatch #(parameter CLK_FREQ = 50000000)
(
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    reg [127:0] sec_counter = 0;
    reg [127:0] min_counter = 0;
    reg [127:0] hour_counter = 0;
    reg [127:0] clk_counter = 0;
    wire one_sec_pulse = ~clk_counter;

    // Internal Clock Divider
    always @(posedge clk) begin
        if (reset) begin
            sec_counter <= 0;
            min_counter <= 0;
            hour_counter <= 0;
            clk_counter <= 0;
        end else begin
            if (one_sec_pulse) begin
                clk_counter <= clk_counter + 1;
                if (clk_counter >= CLK_FREQ - 1) begin
                    clk_counter <= 0;
                    sec_counter <= sec_counter + 1;
                    if (sec_counter >= 6) begin
                        sec_counter <= 0;
                        min_counter <= min_counter + 1;
                        if (min_counter >= 6) begin
                            min_counter <= 0;
                            hour_counter <= hour_counter + 1;
                        end
                    end
                end
            end
        end
    end

    // Stopwatch Operation
    always @(posedge clk) begin
        if (start_stop) begin
            if (one_sec_pulse) begin
                if (sec_counter == 0) begin
                    seconds <= 0;
                end else begin
                    seconds <= sec_counter;
                end
                if (min_counter == 0) begin
                    minutes <= 0;
                end else begin
                    minutes <= min_counter;
                end
                if (hour_counter == 0) begin
                    hour <= 0;
                end else begin
                    hour <= 1;
                end
            end
        end else begin
            if (one_sec_pulse) begin
                seconds <= sec_counter;
                minutes <= min_counter;
                hour <= hour_counter;
            end
        end
    end

    // Reset
    always @(posedge reset) begin
        if (reset) begin
            seconds <= 0;
            minutes <= 0;
            hour <= 0;
        end
    end

endmodule
