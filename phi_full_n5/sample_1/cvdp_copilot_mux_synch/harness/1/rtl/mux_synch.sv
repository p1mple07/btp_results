module mux_synch (

	input [7:0] data_in,   				//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
	input nrst,                    		//asynchronous reset
	output reg [7:0] data_out 
);

reg [7:0] synced_data;
reg enable_sync;

// Synchronize req signal
always @(posedge src_clk) begin
    if (!nrst) begin
        enable_sync <= 0;
    end else begin
        enable_sync <= req;
    end
end

// Synchronize data_in to data_out
always @(posedge dst_clk) begin
    if (!nrst) begin
        data_out <= 8'b0000_0000;
    end else begin
        if (enable_sync) begin
            synced_data <= data_in;
            data_out <= synced_data;
        end
    end
end

// Reset all flip-flops
always @(negedge rst) begin
    data_out <= 8'b0000_0000;
end

endmodule
