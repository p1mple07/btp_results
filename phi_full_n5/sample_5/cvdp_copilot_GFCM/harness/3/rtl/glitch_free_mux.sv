module glitch_free_mux
(
    input clk1,		//input clk1
    input clk2,		// input clk2
    input rst_n,	// async reset
    input sel,		// selection line
    output reg clkout	// clock output
);

// Two-flop clock synchronizers for clk1_enable and clk2_enable
reg clk1_sync_1, clk1_sync_2;
reg clk2_sync_1, clk2_sync_2;

// Synchronizer for clk1_enable
always @(posedge clk1 or negedge rst_n) begin
    if (~rst_n) begin
        clk1_sync_1 <= 0;
        clk1_sync_2 <= 0;
    end else begin
        clk1_sync_1 <= clk1;
        clk1_sync_2 <= clk1_sync_1;
    end
end

// Synchronizer for clk2_enable
always @(posedge clk2 or negedge rst_n) begin
    if (~rst_n) begin
        clk2_sync_1 <= 0;
        clk2_sync_2 <= 0;
    end else begin
        clk2_sync_1 <= clk2;
        clk2_sync_2 <= clk2_sync_1;
    end
end

// Output logic
always @(posedge clk1_sync_2 or posedge clk2_sync_2 or posedge rst_n) begin
    if (rst_n) begin
        clkout <= 0;
    end else begin
        // clkout logic using synchronized signals
        if (sel) begin
            if (clk2_sync_2) begin
                clkout <= clk2;
            end else begin
                clkout <= clk1;
            end
        end else begin
            if (clk1_sync_2) begin
                clkout <= clk1;
            end else begin
                clkout <= clk2;
            end
        end
    end
end

endmodule
