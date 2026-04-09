
module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output  clkout	// clock output
);

// Two-flop clock synchronizers
reg clk1_sync_reg, clk1_sync_next;
reg clk2_sync_reg, clk2_sync_next;

always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        clk1_sync_reg <= 0;
        clk1_sync_next <= 0;
    end else begin
        clk1_sync_reg <= clk1_sync_next;
        clk1_sync_next <= clk1_reg ^ sel;
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        clk2_sync_reg <= 0;
        clk2_sync_next <= 0;
    end else begin
        clk2_sync_reg <= clk2_sync_next;
        clk2_sync_next <= clk2_reg ^ sel;
    end
end

reg clk1_reg, clk2_reg;

// Synchronize clk1
always @(posedge clk1_sync_reg or negedge rst_n) begin
    if (!rst_n) begin
        clk1_reg <= 0;
    end else begin
        clk1_reg <= clk1_sync_next;
    end
end

// Synchronize clk2
always @(posedge clk2_sync_reg or negedge rst_n) begin
    if (!rst_n) begin
        clk2_reg <= 0;
    end else begin
        clk2_reg <= clk2_sync_next;
    end
end

// OUTPUT LOGIC
assign clkout = (clk1 & clk1_reg) | (clk2 & clk2_reg);

endmodule
