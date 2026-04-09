module clock_divider #(
    parameter WIDTH = 1
)(
    input logic clk,
    input logic rst_n,
    input logic [1:0] sel,
    output logic clk_out
);

reg enable;

always @(posedge clk) begin
    if (!rst_n) begin
        clk_out <= 1'b0;
        enable <= 0;
    end else begin
        enable <= 1;
        if (sel == 2'b00) 
            clk_out <= clk / 2;
        else if (sel == 2'b01) 
            clk_out <= clk / 4;
        else if (sel == 2'b10) 
            clk_out <= clk / 8;
        else 
            clk_out <= 1'b0;
    end
end

always @(posedge clk) begin
    if (!enable) clk_out <= 1'b0;
end

endmodule
