module mux_synch (

	input [7:0] data_in,   				//asynchronous data input
	input req,                  		//indicating that data is available at the data_in input
	input dst_clk,                 		//destination clock
	input src_clk,                 		//source clock
	input nrst,                    		//asynchronous reset 
	output reg [7:0] data_out ); 		//synchronized version of data_in to the destination clock domain

    reg [1:0] sync_state;
    reg [7:0] sync_data;

    // Two flip-flops for synchronization
    always @(posedge dst_clk) begin
        if (nrst) begin
            sync_state <= 2'b00;
            sync_data <= 8'b0000_0000;
        end else if (sync_state == 2'b01) begin
            sync_data <= data_out;
            sync_state <= 2'b00;
        end else begin
            sync_data <= data_out;
            sync_state <= sync_state + 1;
        end
    end

    // Select data based on req and synchronize it
    always @(posedge src_clk) begin
        if (req) begin
            if (sync_state == 2'b00) begin
                data_out <= data_in;
                sync_state <= 2'b01;
            end
        end
    end

endmodule

module nff (

	input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
	input dst_clk,     								//destination domain clock.
	input rst,         								//asynchronous active-low reset
	output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
	                   );

    reg [1:0] sync_state;
    reg syncd_reg;

    // Two flip-flops for synchronization
    always @(posedge dst_clk) begin
        if (rst) begin
            syncd_reg <= 8'b0000_0000;
            sync_state <= 2'b00;
        end else if (sync_state == 2'b01) begin
            syncd_reg <= d_in;
            sync_state <= 2'b00;
        end else begin
            syncd_reg <= d_in;
            sync_state <= sync_state + 1;
        end
    end

    assign syncd = syncd_reg;

endmodule
