module piso_8bit(
    input wire clk,
    input wire rst,
    output reg serial_out
);

reg [7:0] tmp;

always @(posedge clk) begin
    if (rst == 1'b0) begin
        tmp <= 8'b0000001;
    end else begin
        if (tmp == 8'b1111111) begin
            tmp <= 8'b0000000;
        end else begin
            tmp <= tmp + 1;
        end
    end
end

assign serial_out = tmp[0];

endmodule