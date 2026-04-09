
module piso_8bit (
    input wire clk,
    input wire rst,
    output reg serial_out
);

reg [7:0] tmp;
reg [7:0] counter;

always @(posedge clk or posedge rst) begin
    if (!rst) begin
        tmp <= 8'b00000001; // 0000_0001
        counter <= 0;
    end else begin
        counter <= counter + 1;
        if (counter == 255) counter <= 0;
        tmp <= tmp + 1;
    end
end

always @(*) begin
    serial_out = tmp[7];
end

endmodule
