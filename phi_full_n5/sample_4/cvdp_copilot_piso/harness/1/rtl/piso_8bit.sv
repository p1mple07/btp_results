module piso_8bit (
    input clk,
    input rst,
    output reg serial_out
);
    reg [7:0] tmp;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tmp <= 8'b0000_0001;
            serial_out <= 1'b0;
        end else begin
            if (tmp == 8'b1111_1111) begin
                tmp <= 8'b0000_0000;
                serial_out <= ~serial_out;
            end else begin
                tmp <= tmp + 1'b1;
                serial_out <= tmp[7];
            end
        end
    end
endmodule
