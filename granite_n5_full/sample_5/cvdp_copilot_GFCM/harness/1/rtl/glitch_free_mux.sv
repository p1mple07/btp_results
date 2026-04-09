module glitch_free_mux(
    input wire clk1,
    input wire clk2,
    input wire sel,
    input wire rst_n,
    output logic clkout
);

logic clk1_en;
logic clk2_en;

always_ff @(posedge clk1 or negedge rst_n) begin
    if (!rst_n) begin
        clk1_en <= 1'b0;
    end else begin
        clk1_en <= ~sel;
    end
end

always_ff @(posedge clk2 or negedge rst_n) begin
    if (!rst_n) begin
        clk2_en <= 1'b0;
    end else begin
        clk2_en <= sel;
    end
end

assign clkout = clk1_en? clk1 : clk2;

endmodule