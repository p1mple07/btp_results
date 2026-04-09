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

    // Internal variables for each counter
    reg [3:0] hr_counter, min_counter, sec_counter;

    // Reset logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hr_counter <= 4'b0000;
            min_counter <= 4'b0000;
            sec_counter <= 4'b0000;
        end else begin
            if (sec_counter == 4'b1001) begin // 9 seconds
                sec_counter <= 4'b0000;
                if (min_counter == 4'b1001) begin // 9 minutes
                    min_counter <= 4'b0000;
                    if (hr_counter == 4'b1001) begin // 9 hours
                        hr_counter <= 4'b0000;
                    end else begin
                        hr_counter <= hr_counter + 1;
                    end
                end
            end

            if (sec_counter == 4'b0100) begin // 4 seconds
                sec_counter <= 4'b0001;
            end

            if (sec_counter == 4'b0010) begin // 2 seconds
                sec_counter <= 4'b0001;
            end

            if (sec_counter == 4'b0001) begin // 1 second
                sec_counter <= 4'b0001;
            end

            if (sec_counter == 4'b0000) begin // 0 seconds
                sec_counter <= 4'b0000;
            end

            if (min_counter == 4'b1001) begin // 9 minutes
                min_counter <= 4'b0001;
            end

            if (min_counter == 4'b0100) begin // 4 minutes
                min_counter <= min_counter + 1;
            end

            if (min_counter == 4'b0001) begin // 1 minute
                min_counter <= min_counter + 1;
            end

            if (min_counter == 4'b0000) begin // 0 minutes
                min_counter <= 4'b0000;
            end

            if (hr_counter == 4'b1001) begin // 9 hours
                hr_counter <= 4'b0000;
            end

            hr_counter <= hr_counter + 1;
        end
    end

    // Output logic
    always @(posedge clk) begin
        ms_hr = hr_counter[3];
        ls_hr = hr_counter[0];
        ms_min = min_counter[3];
        ls_min = min_counter[0];
        ms_sec = sec_counter[3];
        ls_sec = sec_counter[0];
    end

endmodule
