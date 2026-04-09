module dig_stopwatch #(
    parameter CLK_FREQ = 50000000
) (
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    reg [2:0] sec_cnt, min_cnt, hour_cnt;

    initial begin
        sec_cnt = 0;
        min_cnt = 0;
        hour_cnt = 0;
    end

    always @(posedge clk) begin
        if (reset) begin
            sec_cnt = 0;
            min_cnt = 0;
            hour_cnt = 0;
        end else if (start_stop) begin
            if (sec_cnt == 60) begin
                sec_cnt = 0;
                min_cnt = min_cnt + 1;
                if (min_cnt == 60) begin
                    min_cnt = 0;
                    hour_cnt = hour_cnt + 1;
                    hour = 1;
                } else {
                    hour = 0;
                }
            }
            if (min_cnt == 60) begin
                min_cnt = 0;
                sec_cnt = sec_cnt + 1;
            }
            if (sec_cnt == 60) begin
                sec_cnt = 0;
            }
        end else begin
            sec_cnt = 0;
            min_cnt = 0;
            hour_cnt = 0;
        end
    end

    assign seconds = sec_cnt;
    assign minutes = min_cnt;
    assign hour = hour_cnt;

endmodule
