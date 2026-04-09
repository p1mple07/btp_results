module piso_8bit (clk, rst, serial_out);

reg [7:0] tmp;
reg [1:0] count;

always @(posedge clk) begin
    if (!rst) begin
        serial_out <= 1'b0;
        tmp <= 8'b0;
    end else begin
        if (++count == 256) begin
            serial_out <= 1'b1;
            count <= 8'b0;
        end else begin
            serial_out <= tmp[7];
            tmp <= tmp + 1;
        end
    end
end

initial begin
    rst = 1;
    tmp = 8'b00000001;
    serial_out = 1'b0;
end

endmodule
