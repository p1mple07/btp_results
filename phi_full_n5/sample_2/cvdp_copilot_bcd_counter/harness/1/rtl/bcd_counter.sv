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

    // Internal counters
    reg [3:0] sec_counter = 0;
    reg [3:0] min_counter = 0;
    reg [3:0] hr_counter = 0;

    // Internal counters for BCD representation
    reg [3:0] bcd_sec;
    reg [3:0] bcd_min;
    reg [3:0] bcd_hr;

    // Conversion function for BCD
    function [4:0] bcd_convert(input [3:0] dec);
        bcd_convert = dec;
        if (dec > 9) begin
            bcd_convert[3] = 1;
            dec = dec % 10;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sec_counter <= 0;
            min_counter <= 0;
            hr_counter <= 0;
            bcd_sec <= 0;
            bcd_min <= 0;
            bcd_hr <= 0;
        end else begin
            // Seconds counter
            sec_counter <= sec_counter + 1;
            if (sec_counter == 9) begin
                sec_counter <= 0;
                ms_sec <= bcd_convert(sec_counter + 1);
                bcd_sec <= bcd_convert(sec_counter);
            end

            // Minutes counter
            min_counter <= min_counter + 1;
            if (min_counter == 9) begin
                min_counter <= 0;
                ls_min <= bcd_convert(min_counter);
                ms_min <= bcd_convert(min_counter + 1);
                bcd_min <= bcd_convert(min_counter);
            end

            // Hours counter
            hr_counter <= hr_counter + 1;
            if (hr_counter == 10) begin
                hr_counter <= 0;
                ls_hr <= bcd_convert(hr_counter);
                ms_hr <= bcd_convert(hr_counter + 1);
                bcd_hr <= bcd_convert(hr_counter);
            end
        end
    end

    // Display the BCD counters
    assign ms_hr = bcd_hr[3];
    assign ls_hr = bcd_hr[2:0];
    assign ms_min = bcd_min[3];
    assign ls_min = bcd_min[2:0];
    assign ms_sec = bcd_sec[3];
    assign ls_sec = bcd_sec[2:0];

endmodule
