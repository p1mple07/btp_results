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


// CLK1 ENABLE LOGIC
always@(posedge clk1 or negedge rst_n  ) begin
        if (~rst_n) begin
            clk1_enable <= 0 ; 
        end else begin
            clk1_enable <= ~ clk2_enable & ~sel  ;
        end 
end

// CLK2 ENABLE LOGIC
always@(posedge clk2 or negedge rst_n  ) begin
       if (~rst_n) begin
           clk2_enable <= 0 ; 
       end else begin
           clk2_enable <= ~ clk1_enable & sel  ;
       end 
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable) ;

endmodule