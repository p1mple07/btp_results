module reverse_bits(
	input [31:0] num_in, // Inputbus 32 Bits
	output reg [31:0] num_out // Outputbus 32 Bits
);

always @(*) begin
	num_out = 0;
	for (int i=0; i<32; i++) begin
		num_out[i] = num_in[31-i];
	end
end

endmodule