module clock_divider(
    input wire clk,
    input wire rst_n,
    input wire [1:0] sel,
    output reg clk_out
);

reg clk_temp;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        clk_temp <= 0;
    else begin
        case (sel)
            2'b00: clk_temp <= clk;
            2'b01: clk_temp <= ~clk;
            2'b10: clk_temp <= ~clk;
        default: clk_temp <= 0;
        endcase
    end
end

always @(*) begin
    clk_out = clk_temp;
end

endmodule
