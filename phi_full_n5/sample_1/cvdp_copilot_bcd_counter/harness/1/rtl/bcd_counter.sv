module bcd_counter (
    input clk,
    input rst,
    output reg [3:0] ms_hr,
    output reg [3:0] ls_hr,
    output reg [3:0] ms_min,
    output reg [3:0] ls_min,
    output reg [3:0] ms_sec,
    output reg [3:0] ls_sec
);

    // Internal states
    reg [3:0] sec, min, hr;

    // Reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec <= 0;
            min <= 0;
            hr <= 0;
            ms_sec <= 0;
            ls_sec <= 0;
            ms_min <= 0;
            ls_min <= 0;
            ms_hr <= 0;
            ls_hr <= 0;
        end else begin
            if (sec == 9 && ls_sec == 9) begin
                sec <= 0;
                ms_sec <= 0;
                if (min == 5 && ms_sec == 5) begin
                    min <= 0;
                    ms_min <= 0;
                    if (hr == 5 && ms_min == 5) begin
                        hr <= 0;
                        ms_hr <= 0;
                        min <= 0;
                    end
                end
            end

            sec <= sec + 1;
            min <= min + (sec == 9);
            hr <= hr + (min == 5);

            ms_sec <= ms_sec + 1;
            ls_sec <= ls_sec + 1;
            ms_min <= ms_min + (ls_sec == 9);
            ls_min <= ls_min + (ms_sec == 5);
            ms_hr <= ms_hr + (ls_min == 5);
            ls_hr <= ls_hr + (ms_sec == 5);
        end
    end

    // Output logic
    assign ms_hr = ls_hr << 4 | ms_hr;
    assign ls_hr = ls_hr;
    assign ms_min = ls_min << 4 | ms_min;
    assign ls_min = ls_min;
    assign ms_sec = ls_sec << 4 | ms_sec;
    assign ls_sec = ls_sec;
endmodule
