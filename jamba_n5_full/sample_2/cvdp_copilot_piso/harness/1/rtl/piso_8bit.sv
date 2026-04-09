module piso_8bit(
    input clk,
    input rst,
    output reg serial_out
);

    reg [7:0] tmp;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            tmp <= 0;
            serial_out <= 0;
        end else begin
            if (clk) begin
                tmp = tmp + 1;
                if (tmp == 256) begin
                    tmp <= 0;
                    serial_out <= serial_out ^ 1;
                end else serial_out <= tmp & 1;
            end
        end
    end

endmodule
