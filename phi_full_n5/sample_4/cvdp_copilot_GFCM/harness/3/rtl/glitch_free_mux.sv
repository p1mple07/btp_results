
module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

// Two-flop clock synchronizers
reg clk1_sync_reg, clk1_sync_reg_2 ;
reg clk2_sync_reg, clk2_sync_reg_2 ;

// Synchronized clk1_enable
always@(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        clk1_sync_reg <= 0;
        clk1_sync_reg_2 <= 0;
    end else begin
        clk1_sync_reg <= clk1;
        clk1_sync_reg_2 <= clk1_sync_reg;
    end
end

// Synchronized clk2_enable
always@(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        clk2_sync_reg <= 0;
        clk2_sync_reg_2 <= 0;
    end else begin
        clk2_sync_reg <= clk2;
        clk2_sync_reg_2 <= clk2_sync_reg;
    end
end

// Synchronized enable logic
always@(posedge clk1_sync_reg_2 or posedge clk2_sync_reg) begin
    if (clk1_sync_reg_2) begin
        if (sel) begin
            clk1_enable <= 0;
        end else begin
            clk1_enable <= ~clk2_sync_reg & ~sel;
        end
    end else begin
        if (sel) begin
            clk2_enable <= 1;
        end else begin
            clk2_enable <= ~clk1_sync_reg & sel;
        end
    end
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_enable) | (clk2 & clk2_enable);

endmodule
