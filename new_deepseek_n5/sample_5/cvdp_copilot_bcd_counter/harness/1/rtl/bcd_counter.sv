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

    // Counters for seconds, minutes, and hours
    reg [5:0] sec, min, hr;

    // Always block to handle clock edge
    always clock_edge clock begin
        // Reset counters on reset
        if (rst) begin
            sec = 0;
            min = 0;
            hr = 0;
        end else begin
            // Increment seconds
            sec = sec + 1;
            // Reset and increment minutes on overflow of seconds
            if (sec >= 60) begin
                sec = 0;
                min = min + 1;
                // Reset and increment hours on overflow of minutes
                if (min >= 60) begin
                    min = 0;
                    hr = hr + 1;
                    // Reset hours on overflow of hours
                    if (hr >= 24) begin
                        hr = 0;
                    end
                end
            end
        end
    end

    // Output signals
    ms_hr = (hr >> 4) & 0xF;
    ls_hr = hr & 0xF;
    ms_min = (min >> 4) & 0xF;
    ls_min = min & 0xF;
    ms_sec = (sec >> 4) & 0xF;
    ls_sec = sec & 0xF;
endmodule