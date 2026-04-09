module encoder_64b66b (
	input wire clk_in, rst_in,
	input wire [63:0] encoder_data_in,
	input wire [7:0] encoder_control_in,
	output reg [65:0] encoder_data_out
);

always @(posedge clk_in or posedge rst_in) begin
	if (rst_in == 1'b1) begin
		encoder_data_out <= 66'b0;
	end else begin
		case (encoder_control_in)
			8'b00000000:
				encoder_data_out <= {2'b01, encoder_data_in};
			default:
				encoder_data_out <= {2'b10, 64'h000000000000000};
		endcase
	end
end

endmodule