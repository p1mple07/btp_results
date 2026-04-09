module dig_stopwatch #(parameter CLK_FREQ = 50000000)
(
    input wire clk,
    input wire reset,
    input wire start_stop,
    output reg [5:0] seconds,
    output reg [5:0] minutes,
    output reg hour
);

    reg [31:0] sec_count, min_count, hour_count;
    always_ff @(posedge clk) begin
        if (reset) begin
            sec_count <= 0;
            min_count <= 0;
            hour_count <= 0;
        end else begin
            if (start_stop) begin
                if (sec_count == 59) begin
                    sec_count <= 0;
                    min_count <= min_count + 1;
                end else begin
                    sec_count <= sec_count + 1;
                end
                if (min_count == 59) begin
                    min_count <= 0;
                    hour_count <= hour_count + 1;
                end
            end else begin
                sec_count <= 0;
                min_count <= 0;
                hour_count <= 0;
            end
        end
    end

    always_comb begin
        hour <= hour_count == 1 ? 1 : 0;
        seconds <= sec_count;
        minutes <= min_count;
    end

endmodule
