module glitch_free_mux (
    input clk1,
    input clk2,
    input sel,
    input rst_n,
    output reg clkout
);

    wire clkout_current;

    always @(posedge clk1 or posedge clk2 or posedge rst_n) begin
        if (rst_n) begin
            clkout_current <= 0;
        end else begin
            if (sel == 0) begin
                clkout_current <= clk1;
            end else begin
                clkout_current <= clk2;
            end
        end
    end

    assign clkout = clkout_current;

endmodule
