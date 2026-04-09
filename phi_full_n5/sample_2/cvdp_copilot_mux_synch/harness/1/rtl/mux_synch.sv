module mux_synch (
	input [7:0] data_in,   				//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain

	reg [7:0] sync_reg;

	always @(posedge dst_clk) begin
		if (!nrst) begin
			sync_reg <= 8'b0000_0000;
		end else if (req) begin
			sync_reg <= {sync_reg[6:0], data_in};
		end
	end

	always @(posedge src_clk) begin
		if (!nrst) begin
			data_out <= 8'b0000_0000;
		end else if (req) begin
			data_out <= sync_reg;
		end
	end

endmodule

module nff (
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	);

	reg [7:0] sync_reg;

	always @(posedge dst_clk) begin
		if (!rst) begin
			sync_reg <= 8'b0000_0000;
		end else begin
			sync_reg <= {sync_reg[6:0], d_in};
		end
	end

	assign syncd = sync_reg;

endmodule
