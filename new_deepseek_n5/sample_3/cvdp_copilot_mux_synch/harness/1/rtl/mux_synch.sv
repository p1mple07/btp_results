module mux_synch (
	input [7:0] data_in,
	input req,
	input dst_clk,
	input src_clk,
	input nrst,
	output reg [7:0] data_out
)
	// Create enable signal using nff synchronizer
	// First stage of synchronizer
	// nff1 is sensitive to positive edge of src_clk (source domain)
	nff (req, src_clk, nrst) nff1;
	// nff2 is sensitive to positive edge of dst_clk (destination domain)
	nff (nff1 syncd, dst_clk, nrst) nff2;
	// Use enable signal to select data
	always posedge src_clk begin
		data_out = nff2.syncd & data_in;
	end
endmodule

module nff (
	input d_in,
	input dst_clk,
	input rst,
	output reg syncd
)
	// First flip-flop is sensitive to positive edge of dst_clk
	flip_flop d_in d1 (dst_clk, rst);
	// Second flip-flop is also sensitive to positive edge of dst_clk
	flip_flop d1.d d2 (dst_clk, rst);
	// Output is the second flip-flop's output
.syncd = d2.d;
endmodule