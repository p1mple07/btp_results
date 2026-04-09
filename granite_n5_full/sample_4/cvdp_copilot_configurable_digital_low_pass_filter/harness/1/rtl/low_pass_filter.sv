module low_pass_filter #(
	parameter DATA_WIDTH=16,
	parameter COEFF_WIDTH=16,
	parameter NUM_TAPS=8,
	localparam NBW_MULT = $clog2(DATA_WIDTH+COEFF_WIDTH),
	localparam TAP_WIDTH = NUM_TAPS*DATA_WIDTH
)(
	input clk,
	input reset,
	input [TAP_WIDTH-1:0] coeffs,
	input [DATA_WIDTH-1:0] data_in,
	input valid_in,
	output reg [NBW_MULT-1:0] data_out,
	output reg valid_out
);

reg [TAP_WIDTH-1:0] coeffs_r;
reg [DATA_WIDTH-1:0] data_in_r;
reg valid_in_r;
wire [DATA_WIDTH*(NUM_TAPS)-1:0] conv_out;

// Sequential and Combinational Logic
always @(posedge clk) begin
	if (reset) begin
		coeffs_r <= '0;
		data_in_r <= '0;
		valid_in_r <= 0;
	end else begin
		coeffs_r <= coeffs;
		data_in_r <= data_in;
		valid_in_r <= valid_in;
	end
end

// Element-wise Multiplication
assign conv_out = &{coeffs_r, data_in_r} * &coeffs_r; // bitwise AND of coeffs_r and data_in_r, then take the conjunction of these two bitstreams.

// Summation
wire [DATA_WIDTH*NUM_TAPS-1:0] conv_out_r;
reg [NBW_MULT-1:0] sum;

generate
	for (i = 0; i < NUM_TAPS; i++) begin
		assign conv_out_r[i*DATA_WIDTH-1:0] = conv_out[i*DATA_WIDTH-1:0];
	end
endgenerate

wire [NBW_MULT-1:0] sum_r;

// Edge case handling

// Output Signals
assign sum_r = conv_out_r[0] + conv_out_r[1] +... + conv_out_r[NUM_TAPS-1];
assign valid_out = valid_in_r;
assign data_out = sum_r;

endmodule