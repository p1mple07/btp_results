module clock_divider (
    input wire clk,
    input wire rst_n,
    input wire [1:0] sel,
    output reg clk_out
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_out <= 1'b0;
    end else begin
        case (sel)
            2'b00: clk_out <= clk / 2;
            2'b01: clk_out <= clk / 4;
            2'b10: clk_out <= clk / 8;
            default: clk_out <= 1'b0; // Out-of-range value, hold low
        endcase
    end
end

endmodule