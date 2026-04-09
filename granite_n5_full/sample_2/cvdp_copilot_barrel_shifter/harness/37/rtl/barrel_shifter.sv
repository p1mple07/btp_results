module barrel_shifter #(parameter DATA_WIDTH=16, parameter SHIFT_BITS_WIDTH=4)(
	input [DATA_WIDTH-1:0] data_in,
	input [SHIFT_BITS_WIDTH-1:0] shift_bits,
	input rotate_left_right,
	output reg [DATA_WIDTH-1:0] data_out
);

always @(*) begin
	if (rotate_left_right == 1) begin
		// Perform a rotate operation
		reg [DATA_WIDTH-1:0] rotated_data;
		
		for (int i=0; i<DATA_WIDTH; i++) begin
			rotated_data[i] = data_in[(i+shift_bits)%DATA_WIDTH];
		}
		
		data_out = rotated_data;
	end else begin
		// Perform a left or right shift
		case (shift_bits)
			0: data_out = data_in;
			default: data_out = (rotate_left_right == 0)? {data_in[DATA_WIDTH-1:shift_bits], data_in[DATA_WIDTH-shift_bits-1:0]} : {data_in[shift_bits-1:0], data_in[DATA_WIDTH-1:shift_bits]};
		endcase
	end
end

endmodule