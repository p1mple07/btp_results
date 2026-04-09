module glitch_free_mux (
    input clk1,
    input clk2,
    input rst_n,
    input sel,
    output clkout
);

reg clkout_reg;
reg clk1_enable, clk2_enable;
reg clk1_out, clk2_out;

// Synchronise the enable signals across the two clock domains
always @(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        clk1_enable <= 1'b0;
    end else begin
        #5;
        clk1_enable <= ~clk2_enable;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        clk2_enable <= 1'b0;
    end else begin
        #5;
        clk2_enable <= ~clk1_enable;
    end
end

// Compute the output based on the current enable state
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable);

endmodule
