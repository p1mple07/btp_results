module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

reg clkout_reg;
reg clk1_enable, clk2_enable;
reg sel1, sel0;  // Changed to D flip-flops
reg sel1_counter, sel0_counter;  // Changed to D flip-flops

// Enable logic for sel=1
always@(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        sel1 <= 0;
        sel1_counter <= 0;
    end else begin
        sel1 <= 1;
        sel1_counter <= 2;
    end
end

// Enable logic for sel=0
always@(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        sel0 <= 0;
        sel0_counter <= 0;
    end else begin
        sel0 <= 1;
        sel0_counter <= 2;
    end
end

// Wait for sel change to take effect
always@(posedge sel1_counter or negedge rst_n) begin
    if (~rst_n) begin
        sel1_enable <= 0;
    end else begin
        sel1_enable <= sel1_counter == 2;
    end
end

always@(posedge sel0_counter or negedge rst_n) begin
    if (~rst_n) begin
        sel0_enable <= 0;
    end else begin
        sel0_enable <= sel0_counter == 2;
    end
end

// Output logic
assign clkout = (clk1 & sel1_enable) | (clk2 & sel0_enable);

endmodule