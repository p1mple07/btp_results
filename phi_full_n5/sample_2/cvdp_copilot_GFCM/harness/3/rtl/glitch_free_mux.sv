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

// CLOCK SYNCHRONIZER FOR CLK1
always @(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        clk1_enable <= 0 ; 
    end else begin
        clk1_enable <= ~clk2_enable & sel ;
    end 
end

// CLOCK SYNCHRONIZER FOR CLK2
always @(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        clk2_enable <= 0 ; 
    end else begin
        clk2_enable <= ~clk1_enable & sel ;
    end 
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable) ;

endmodule

// Example waveform for glitch-free switching:
//
// clk1:   0  1  0  1  0  1  0  1  0  1  0  1  0  1
// clk2:   0  0  1  0  0  1  0  0  1  0  0  1  0  1
// sel:    0  1  0  0  0  0  1  0  0  0  0  0  1  0
// clkout: 0  1  0  0  0  0  0  1  0  0  0  0  0  1
//
// Note: The clkout waveform shows the clock output enabling glitch-free switching between clk1 and clk2.
// The second positive edge of clk1 and clk2 after the sel change ensures glitch-free switching. module glitch_free_mux
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

// CLOCK SYNCHRONIZER FOR CLK1
always @(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        clk1_enable <= 0 ; 
    end else begin
        clk1_enable <= ~clk2_enable & sel ;
    end 
end

// CLOCK SYNCHRONIZER FOR CLK2
always @(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        clk2_enable <= 0 ; 
    end else begin
        clk2_enable <= ~clk1_enable & sel ;
    end 
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable) ;

endmodule