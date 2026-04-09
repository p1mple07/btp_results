module bcd_counter(
    input clk,
    input rst,
    output reg [3:0] ms_hr,
    output reg [3:0] ls_hr,
    output reg [3:0] ms_min,
    output reg [3:0] ls_min,
    output reg [3:0] ms_sec,
    output reg [3:0] ls_sec
);

reg [7:0] hr = 0;
reg [7:0] min = 0;
reg [7:0] sec = 0;

always @(posedge clk) begin
    if (rst) begin
        ms_hr <= 4'b0000;
        ls_hr <= 4'b0000;
        ms_min <= 4'b0000;
        ls_min <= 4'b0000;
        ms_sec <= 4'b0000;
        ls_sec <= 4'b0000;
    end else begin
        if (sec == 59) begin
            sec <= 0;
            if (min == 59) begin
                min <= 0;
                if (hr == 23) begin
                    hr <= 0;
                } else begin
                    hr <= hr + 1;
                end
            end else begin
                min <= min + 1;
            end
        end else begin
            sec <= sec + 1;
        end
        ms_sec <= sec[3:0];
        ls_sec <= sec[7:4];
        ms_min <= min[3:0];
        ls_min <= min[7:4];
        ms_hr <= hr[3:0];
        ls_hr <= hr[7:4];
    end
end

endmodule