module mux_synch (
	input [7:0] data_in,   				//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain

    // Two-flip-flop synchronizer
    reg sync_reg1, sync_reg2;

    // Sync flip-flop 1
    always @(posedge dst_clk) begin
        if (!nrst) begin
            sync_reg1 <= 8'b0;
        end else begin
            sync_reg1 <= (req && data_in) ? data_in : 8'bz;
        end
    end

    // Sync flip-flop 2
    always @(posedge dst_clk) begin
        if (!nrst) begin
            sync_reg2 <= 8'b0;
        end else begin
            sync_reg2 <= sync_reg1;
        end
    end

    // Output data
    assign data_out = sync_reg2;

endmodule

module nff  (
	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	);

    // Two-flip-flop synchronizer
    reg sync_reg1, sync_reg2;

    // Sync flip-flop 1
    always @(posedge dst_clk) begin
        if (!rst) begin
            sync_reg1 <= 8'b0;
        end else begin
            sync_reg1 <= d_in;
        end
    end

    // Sync flip-flop 2
    always @(posedge dst_clk) begin
        if (!rst) begin
            sync_reg2 <= 8'b0;
        end else begin
            sync_reg2 <= sync_reg1;
        end
    end

    // Synced output
    assign syncd = sync_reg2;

endmodule
