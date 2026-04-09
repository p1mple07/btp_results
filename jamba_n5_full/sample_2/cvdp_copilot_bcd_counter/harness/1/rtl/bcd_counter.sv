module bcd_counter (
    input clk,
    input rst,
    output reg ms_hr,
    output reg ls_hr,
    output reg ms_min,
    output reg ls_min,
    output reg ms_sec,
    output reg ls_sec
);

reg [3:0] ms_hr_cnt;
reg [3:0] ls_hr_cnt;
reg [3:0] ms_min_cnt;
reg [3:0] ls_min_cnt;
reg [3:0] ms_sec_cnt;
reg [3:0] ls_sec_cnt;

initial begin
    ms_hr_cnt = 0; ls_hr_cnt = 0;
    ms_min_cnt = 0; ls_min_cnt = 0;
    ms_sec_cnt = 0; ls_sec_cnt = 0;
end

always @(posedge clk or posedge rst) begin
    if (!rst) begin
        ms_hr_cnt <= 0; ls_hr_cnt <= 0;
        ms_min_cnt <= 0; ls_min_cnt <= 0;
        ms_sec_cnt <= 0; ls_sec_cnt <= 0;
    end else begin
        // Increment seconds
        if (ls_sec_cnt == 9) begin
            ls_sec_cnt = 0;
            ms_sec_cnt++;
        end else if (ms_sec_cnt == 5) begin
            if (ls_sec_cnt == 9) begin
                ls_sec_cnt = 0;
            end else begin
                ms_sec_cnt++;
            end
        end else if (ms_sec_cnt == 5) begin
            ms_sec_cnt = 0;
            ls_min_cnt++;
        end else if (ls_min_cnt == 9) begin
            ls_min_cnt = 0;
            ms_min_cnt++;
        end else if (ms_min_cnt == 5) begin
            ms_min_cnt = 0;
            ls_hr_cnt++;
        end else if (ls_hr_cnt == 9) begin
            ls_hr_cnt = 0;
            ms_hr_cnt++;
        end else if (ms_hr_cnt == 23) begin
            ms_hr_cnt = 0;
        end
    end
end

endmodule
