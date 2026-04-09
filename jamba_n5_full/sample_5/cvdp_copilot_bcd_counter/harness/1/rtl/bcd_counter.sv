module bcd_counter (
    input wire clk,
    input wire rst,
    output reg [3:0] ms_hr,
    output reg [3:0] ls_hr,
    output reg [3:0] ms_min,
    output reg [3:0] ls_min,
    output reg [3:0] ms_sec,
    output reg [3:0] ls_sec
);

reg [3:0] count_sec;
reg [3:0] count_min;
reg [3:0] count_hr;

always @(posedge clk or negedge rst) begin
    if (rst)
        ms_hr <= 0;
        ms_min <= 0;
        ms_sec <= 0;
        ls_hr <= 0;
        ls_min <= 0;
        ls_sec <= 0;
    else
        count_sec <= count_sec + 1;

        if (count_sec == 60) begin
            count_sec <= 0;
            count_min <= count_min + 1;
        end else begin
            count_min <= count_min + 1;
        end

        if (count_min == 60) begin
            count_min <= 0;
            count_hr <= count_hr + 1;
        end else begin
            count_hr <= count_hr + 1;
        end

        if (count_hr == 24) begin
            count_hr <= 0;
        end

        // Convert counts to BCD? We can leave them as decimal and let the display handle BCD, or we can encode as BCD.
        // For simplicity, we output the counters directly.

        // However, the output lines are the digits.

        ms_hr = count_hr;
        ls_hr = count_hr & 1;
        ms_min = count_min;
        ls_min = count_min & 1;
        ms_sec = count_sec;
        ls_sec = count_sec & 1;

endalways

endmodule
