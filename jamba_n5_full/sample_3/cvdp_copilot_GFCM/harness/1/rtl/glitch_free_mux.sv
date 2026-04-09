module glitch_free_mux (
    input         clk1,  clk2,
    input         sel,
    input         rst_n,
    output reg    clkout
);

    reg [31:0] temp;

    always @(posedge clk1 or posedge clk2) begin
        if (rst_n) clkout <= 1'b0;
        else if (sel == 0)
            temp <= clk1;
        else
            temp <= clk2;
    end

    assign clkout = temp;

endmodule
