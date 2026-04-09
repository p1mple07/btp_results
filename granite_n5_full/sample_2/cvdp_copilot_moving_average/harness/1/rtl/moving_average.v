module moving_average(
	input clk,
	input reset,
	input [11:0] data_in,
	output reg [11:0] data_out
);

reg [11:0] sum_reg;
reg [3:0] count_reg;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		sum_reg <= 0;
		count_reg <= 0;
	end else begin
		sum_reg <= {sum_reg[10:0], data_in};
		count_reg <= count_reg + 1;
		
		if (count_reg == 8) begin
			data_out <= sum_reg / 8;
			count_reg <= 0;
		end
	end
end

endmodule