module convolutional_encoder (
	input wire clk,
	input wire rst,
	input wire data_in,
	output reg encoded_bit1,
	output reg encoded_bit2
);

reg [1:0] shift_register; // 2-bit shift register

always @(posedge clk or posedge rst) begin
	if (rst) begin
		shift_register <= 2'b00;
	end else begin
		shift_register <= {data_in, shift_register[1:0]}; // Shift left by 1 bit and add new data input
	end
end

assign encoded_bit1 = ~((shift_register[1] & shift_register[0]) | (shift_register[0] & shift_register[2])); // XOR operation on the current shift register values
assign encoded_bit2 = ~((shift_register[1] & shift_register[0]) | (shift_register[1] & shift_register[2])); // XOR operation on the current shift register values

endmodule