module glitch_free_mux(
    input rst_n, clk1, clk2, sel,
    output reg clkout
);

parameter T = 2; // Define the fixed phase difference between clk1 and clk2

reg clk1_en, clk2_en; // Enable signals for clk1 and clk2

always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        clk1_en <= 1;
        clk2_en <= 0;
    end else begin
        clk1_en <=!clk1_en; // Toggle clk1_en on rising edge of clk1
    end
end

always @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        clk2_en <= 1;
        clk1_en <= 0;
    end else begin
        clk2_en <=!clk2_en; // Toggle clk2_en on rising edge of clk2
    end
end

assign clkout = clk1_en? clk1 : clk2; // Assign output clock based on enable signals

endmodule