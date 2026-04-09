module mux_synch (

	input [7:0] data_in,   					//asynchronous data input
	input req,                  			//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain

	reg [7:0] flip_flop1, flip_flop2;

	always @(posedge dst_clk or posedge rst) begin
		if (rst) begin
			flip_flop1 <= 8'b0;
			flip_flop2 <= 8'b0;
			data_out <= 8'b0;
		end else if (req) begin
			flip_flop1 <= data_in;
			flip_flop2 <= flip_flop1;
			data_out <= flip_flop2;
		end
	end

endmodule

module nff (

	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

	reg [7:0] flip_flop1, flip_flop2;

	always @(posedge dst_clk or posedge rst) begin
		if (rst) begin
			flip_flop1 <= 8'b0;
			flip_flop2 <= 8'b0;
			syncd <= 8'b0;
		end else if (flip_flop1) begin
			flip_flop2 <= d_in;
			syncd <= flip_flop2;
		end
	end

endmodule
