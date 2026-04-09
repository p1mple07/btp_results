module glitch_free_mux(
    input wire clk1,
    input wire clk2,
    input wire sel,
    input wire rst_n,
    output reg clkout
);

always @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        clkout <= 1'b0; // Low level during reset
    end else begin
        if (sel == 1'b0) begin
            clkout <= 1'b1;
        end else begin
            clkout <= 1'b0;
        end
    end
end

// Disable clk1 on rising edge of clk1, enable clk2 on rising edge of clk2
always @(posedge clk1) begin
    clk1_en <= 1'b1;
end

always @(posedge clk2) begin
    clk2_en <= 1'b1;
end

// Disable clk2 on rising edge of clk2, enable clk1 on rising edge of clk1
always @(posedge clk2) begin
    clk2_en <= 1'b0;
end

always @(posedge clk1) begin
    clk1_en <= 1'b0;
end

endmodule