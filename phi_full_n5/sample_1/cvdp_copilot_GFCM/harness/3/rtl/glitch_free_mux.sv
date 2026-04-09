
module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

reg clkout_reg ;
reg clk1_enable, clk2_enable;
reg clk1_out, clk2_out ;

// Two-flop clock synchronizer for clk1
always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        clk1_enable <= 0;
        clk1_out <= 0;
    end else begin
        clk1_enable <= ~clk2_enable & sel;
        clk1_out <= clk1_enable & clk1;
    end
end

// Two-flop clock synchronizer for clk2
always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        clk2_enable <= 0;
        clk2_out <= 0;
    end else begin
        clk2_enable <= ~clk1_enable & sel;
        clk2_out <= clk2_enable & clk2;
    end
end

// OUTPUT LOGIC
assign clkout = (clk1_out & clk1_enable) | (clk2_out & clk2_enable);

endmodule
