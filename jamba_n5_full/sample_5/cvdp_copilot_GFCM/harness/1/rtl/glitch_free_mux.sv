module glitch_free_mux (
    input wire clk1,
    input wire clk2,
    input wire sel,
    input wire rst_n,
    output wire clkout
);

    assign clkout = (rst_n) ? 1'b0 : (sel == 0 ? clk1 : clk2);

endmodule
