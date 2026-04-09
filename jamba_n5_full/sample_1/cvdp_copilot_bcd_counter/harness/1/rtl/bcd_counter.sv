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

    reg [3:0] seconds;
    reg [3:0] minutes;
    reg [3:0] hours;

    initial begin
        seconds = 0;
        minutes = 0;
        hours = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            seconds = 0;
            minutes = 0;
            hours = 0;
        else
            if (clk.isPositive)
                seconds = seconds + 1;

            if (seconds == 59)
                seconds = 0;
                minutes = minutes + 1;
                if (minutes == 59)
                    minutes = 0;
                    hours = hours + 1;
                    if (hours == 24)
                        hours = 0;
        end
    end

    always @(posedge clk) begin
        ms_hr = hours;
        ls_hr = hours[3:2];
        ms_min = minutes;
        ls_min = minutes[3:2];
        ms_sec = seconds;
        ls_sec = seconds[3:2];
    end

endmodule
