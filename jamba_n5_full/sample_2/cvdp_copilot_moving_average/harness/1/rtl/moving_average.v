module moving_average (
    input wire clk,
    input wire reset,
    input wire [11:0] data_in,
    output wire [11:0] data_out
);

reg [7:0] buffer[0:7];
reg [15:0] sum;
reg oldest;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        buffer[0:7] <= 0;
        sum <= 0;
        oldest <= 0;
    end else begin
        if (data_in != buffer[0]) begin
            oldest <= oldest + 1 mod 8;
            buffer[oldest] <= data_in;
            sum = sum + data_in - buffer[oldest];
        end
    end
end

assign data_out = sum / 8;

endmodule
