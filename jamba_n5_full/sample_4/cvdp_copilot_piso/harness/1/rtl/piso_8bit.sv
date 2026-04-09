module pisor (
    input wire clk,
    input wire rst,
    output reg serial_out
);

reg [7:0] tmp;
reg [7:0] cnt;

always @(posedge clk) begin
    if (!rst) begin
        tmp = 8'b00000001;      // initial value 0000_0001
        cnt <= 8'b0;
    end else begin
        cnt <= cnt + 1;
        if (cnt == 256) cnt <= 8'b0;
    end
end

always @(posedge clk) begin
    if (!rst) serial_out <= 1'b0;
    else serial_out <= tmp[7];
end

endmodule
