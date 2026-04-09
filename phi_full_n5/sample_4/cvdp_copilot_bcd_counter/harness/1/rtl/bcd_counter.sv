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

    reg [3:0] sec_count = 0;
    reg [3:0] min_count = 0;
    reg [3:0] hr_count = 0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec_count <= 0;
            min_count <= 0;
            hr_count <= 0;
        end else begin
            if (sec_count == 9) begin
                sec_count <= 0;
                ms_sec <= (sec_count + 1) >> 1;
            end else begin
                ms_sec <= sec_count + 1;
            end

            if (ms_sec == 5) begin
                ms_sec <= 0;
                min_count <= (ms_sec + 1) >> 1;
            end else begin
                min_count <= ms_sec + 1;
            end

            if (min_count == 9) begin
                min_count <= 0;
                ls_min <= (min_count + 1) >> 1;
            end else begin
                ls_min <= min_count + 1;
            end

            if (ls_min == 6) begin
                ls_min <= 0;
                ms_hr <= (ls_min + 1) >> 1;
            end else if (ms_hr == 3) begin
                ms_hr <= 0;
                ls_hr <= (ms_hr + 1) >> 1;
            end else begin
                ls_hr <= ms_hr + 1;
            end
        end
    end

    always_comb begin
        ms_hr = (hr_count >> 4);
        ls_hr = hr_count & 0x0F;
        ms_min = (min_count >> 4);
        ls_min = min_count & 0x0F;
        ms_sec = (sec_count >> 4);
        ls_sec = sec_count & 0x0F;
    end

endmodule
