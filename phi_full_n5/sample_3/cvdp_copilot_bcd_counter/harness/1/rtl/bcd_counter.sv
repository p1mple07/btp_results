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

    // Internal variables to hold the current state
    reg [3:0] current_hr, current_min, current_sec;

    // Reset the counters on the rising edge of reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_hr <= 4'b0000;
            current_min <= 4'b0000;
            current_sec <= 4'b0000;
        end else begin
            // Increment the seconds counter
            if (current_sec == 4'b1001) begin // 9 seconds
                current_sec <= 4'b0000;
                current_hr <= current_hr + 1;
            end else if (current_sec == 4'b0101) begin // 5 seconds
                current_sec <= 4'b0001;
            end else begin
                current_sec <= current_sec + 1;
            end

            // Increment the minutes counter
            if (current_min == 4'b1001) begin // 9 minutes
                current_min <= 4'b0000;
                current_sec <= 4'b0000;
                current_hr <= current_hr + 1;
            end else if (current_min == 4'b0101) begin // 5 minutes
                current_min <= 4'b0001;
            end else begin
                current_min <= current_min + 1;
            end

            // Increment the hours counter
            if (current_hr == 4'b1111) begin // 23 hours
                current_hr <= 4'b0000;
                current_min <= 4'b0000;
                current_sec <= 4'b0000;
            end else begin
                current_hr <= current_hr + 1;
            end
        end
    end

    // Convert BCD to display format
    always @(current_hr, current_min, current_sec) begin
        ms_hr = current_hr[3];
        ls_hr = current_hr[2];
        ms_min = current_min[3];
        ls_min = current_min[2];
        ms_sec = current_sec[3];
        ls_sec = current_sec[2];
    end

endmodule
