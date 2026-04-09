module bcd_counter(
    input clock,
    input rst,
    output ms_hr,
    output ls_hr,
    output ms_min,
    output ls_min,
    output ms_sec,
    output ls_sec
);

    // Registers to hold the current time in BCD
    reg [3:0] hr, min, sec;

    // Reset all registers on assertion of rst
    always_comb begin
        if (rst) begin
            ms_hr = 0;
            ls_hr = 0;
            ms_min = 0;
            ls_min = 0;
            ms_sec = 0;
            ls_sec = 0;
        end
    end

    // Increment time on positive edge of clock
    clock_edge begin
        // Increment seconds
        while (ls_sec < 9) begin
            ls_sec = ls_sec + 1;
        end
        if (ls_sec == 9) begin
            ls_sec = 0;
            ms_sec = ms_sec + 1;
        end
        while (ms_sec < 5) begin
            ms_sec = ms_sec + 1;
        end
        if (ms_sec == 5) begin
            ms_sec = 0;
            ls_min = ls_min + 1;
        end
        while (ls_min < 9) begin
            ls_min = ls_min + 1;
        end
        if (ls_min == 9) begin
            ls_min = 0;
            ms_min = ms_min + 1;
        end
        while (ms_min < 59) begin
            ms_min = ms_min + 1;
        end
        if (ms_min == 59) begin
            ms_min = 0;
            hr = hr + 1;
        end
        while (hr < 23) begin
            hr = hr + 1;
        end
        if (hr == 23) begin
            hr = 0;
        end
    end
endmodule