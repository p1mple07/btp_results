module clock_divider(
	input logic clk, 
	input logic rst_n,
	input logic [1:0] sel, 
	output logic clk_out
);

logic divided_clk;

always_ff @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		divided_clk <= 1'b0;
	end else if (sel == 2'b00) begin
		divided_clk <= clk;
	end else if (sel == 2'b01) begin
		divided_clk <= clk << 1;
	end else if (sel == 2'b10) begin
		divided_clk <= clk << 2;
	end
end

assign clk_out = divided_clk;

endmodule