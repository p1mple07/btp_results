module bcd_counter(
    input wire clk,
    input wire rst,
    output reg [3:0] ms_hr,
    output reg [3:0] ls_hr,
    output reg [3:0] ms_min,
    output reg [3:0] ls_min,
    output reg [3:0] ms_sec,
    output reg [3:0] ls_sec
);

reg [7:0] sec_count; // 8-bit register to store seconds count
reg [6:0] min_count; // 7-bit register to store minutes count
reg [5:0] hr_count; // 6-bit register to store hours count

always @(posedge clk) begin
    if (rst) begin
        sec_count <= 0;
        min_count <= 0;
        hr_count <= 0;
    end else begin
        sec_count <= sec_count + 1;

        if (sec_count == 60) begin
            sec_count <= 0;
            min_count <= min_count + 1;

            if (min_count == 60) begin
                min_count <= 0;
                hr_count <= hr_count + 1;

                if (hr_count == 24) begin
                    hr_count <= 0;
                end
            end
        end
    end
end

// Convert binary counts to BCD digits
assign ms_hr = sec_count[7:6];
assign ls_hr = sec_count[5:4];
assign ms_min = min_count[7:6];
assign ls_min = min_count[5:4];
assign ms_sec = sec_count[3:2];
assign ls_sec = sec_count[1:0];

endmodule