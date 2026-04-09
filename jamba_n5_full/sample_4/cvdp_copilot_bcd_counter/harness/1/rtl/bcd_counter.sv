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

    always @(posedge clk or posedge rst) begin
        if (!rst) begin
            ms_hr <= 0;
            ls_hr <= 0;
            ms_min <= 0;
            ls_min <= 0;
            ms_sec <= 0;
            ls_sec <= 0;
        end else begin
            if (ms_sec == 9) begin
                ms_sec <= 0;
                ms_min <= ms_min + 1;
            end else if (ms_min == 9) begin
                ms_min <= 0;
                ms_hr <= ms_hr + 1;
            end else begin
                ms_sec <= ms_sec + 1;
            end

            if (ms_min == 9) begin
                ms_min <= 0;
                ms_hr <= ms_hr + 1;
            end else if (ms_sec == 9) begin
                ms_sec <= 0;
                ms_min <= ms_min + 1;
            end else begin
                ms_min <= ms_min + 1;
            end

            if (ms_hr == 23) begin
                ms_hr <= 0;
            end else if (ms_hr == 0 && ms_min == 59) begin
                ms_hr <= 0;
                ms_min <= ms_min + 1;
            end else if (ms_hr == 0 && ms_min == 0 && ms_sec == 59) begin
                ms_hr <= 0;
                ms_min <= ms_min + 1;
                ms_sec <= ms_sec + 1;
            end
        end
    end

endmodule
