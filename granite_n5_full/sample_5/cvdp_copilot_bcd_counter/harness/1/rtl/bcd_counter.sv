module bcd_counter (
    input clk, // Clock input signal
    input rst, // Reset signal
    output reg [3:0] ms_hr, // Most significant digit of the hour counter
    output reg [3:0] ls_hr, // Least significant digit of the hour counter
    output reg [3:0] ms_min, // Most significant digit of the minute counter
    output reg [3:0] ls_min, // Least significant digit of the minute counter
    output reg [3:0] ms_sec, // Most significant digit of the second counter
    output reg [3:0] ls_sec // Least significant digit of the second counter
);

reg [3:0] sec_cnt = 0; // Seconds counter
reg [3:0] min_cnt = 0; // Minutes counter
reg [3:0] hr_cnt = 0; // Hours counter

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ms_hr <= 4'b0000;
        ls_hr <= 4'b0000;
        ms_min <= 4'b0000;
        ls_min <= 4'b0000;
        ms_sec <= 4'b0000;
        ls_sec <= 4'b0000;
        hr_cnt <= 4'b0000;
    end else begin
        sec_cnt <= sec_cnt + 1;

        if (sec_cnt == 60) begin
            sec_cnt <= 0;
            min_cnt <= min_cnt + 1;

            if (min_cnt == 60) begin
                min_cnt <= 0;
                hr_cnt <= hr_cnt + 1;

                if (hr_cnt == 24) begin
                    hr_cnt <= 0;
                end
            }
        end

        ms_sec <= sec_cnt[3:0];
        ls_sec <= sec_cnt[2:0];
        ms_min <= min_cnt[3:0];
        ls_min <= min_cnt[2:0];
        ms_hr <= hr_cnt[3:0];
        ls_hr <= hr_cnt[2:0];
    end
end

endmodule