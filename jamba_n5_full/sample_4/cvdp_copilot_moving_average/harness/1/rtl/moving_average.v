module moving_average (
    input wire clk,
    input wire reset,
    input wire [11:0] data_in,
    output wire [11:0] data_out
);

reg [11:0] sample_buffer[7];
reg [11:0] sum;
wire new_sample;

always @(posedge clk) begin
    if (reset) begin
        for (i in 0 to 7) sample_buffer[i] <= 0;
        sum <= 0;
    end else begin
        new_sample = data_in;
        s[0] <= sample_buffer[7];
        for (i = 1; i < 8; i++) s[i] <= s[i-1];
        s[0] <= new_sample;
        sum = sum + new_sample - s[0];
        data_out = sum / 8;
    end
end

endmodule
