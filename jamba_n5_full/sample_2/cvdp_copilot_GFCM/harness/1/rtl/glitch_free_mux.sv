module glitch_free_mux (
    input clk1, clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    always @(posedge sel) begin
        if (sel == 0) begin
            assign clkout = clk1;
        end else begin
            assign clkout = clk2;
        end
    end

    always @(*) begin
        if (~rst_n) begin
            clkout <= 1'b0;
        end
    end

endmodule
