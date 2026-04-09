module binary_to_one_hot_decoder #(parameter BINARY_WIDTH = 5, OUTPUT_WIDTH = 32)(
	input [BINARY_WIDTH-1:0] binary_in, 
	output reg [OUTPUT_WIDTH-1:0] one_hot_out
);

always @(*) begin
	for (int i = 0; i < OUTPUT_WIDTH; i++) begin
		if (i == binary_in) begin
			one_hot_out[i] = 1'b1;
		end else begin
			one_hot_out[i] = 1'b0;
		end
	end
end

endmodule