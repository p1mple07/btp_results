module mux_synch (

    input [7:0] data_in,   					//asynchronous data input
    input req,                  			//indicating that data is available at the data_in input
    input dst_clk,                 		//destination clock
    input src_clk,                 		//source clock
    input nrst,                    		//asynchronous reset 
    output reg [7:0] data_out,              //synchronized version of data_in to the destination clock domain
    output reg ack_out ); 		

    wire syncd_req, anded_req, syncd_ack;
    reg syncd_req_1, ack;

    // Two-flip-flop synchronizer for the enable input
    nff req_synch_0 (.d_in(req), .dst_clk(dst_clk), .rst(nrst), .syncd(syncd_req));

    // Posedge detector for enable signal
    always_ff @(posedge dst_clk or negedge nrst)
    begin
        if(!nrst)
            data_out <= 1'b0;               					//forcing the output data_in to zero when an active-low asynchronous reset is detected.
        else
            data_out <= data_in;                    				//latching data_in to data_out when the enable signal is available.
    end

    // Synchronized acknowledgment signal generation
    nff enable_synch_1 (.d_in(ack), .dst_clk(src_clk), .rst(nrst), .syncd(syncd_ack));

    // Edge detector circuit for ack_out
    assign ack_out = syncd_ack;

endmodule

module nff (

    input d_in,   									//input data that needs to be synchronized to the dst_clk domain.
    input dst_clk,     								//destination domain clock.
    input rst,         								//asynchronous active-low reset
    output reg  syncd 								//synced output, which is a 2-clock-cycle delayed version of d_in.
    );

    reg dmeta;             								//register to hold output

    always@(posedge dst_clk or negedge rst)  
    begin
        if(!rst)              								//active-low asynchronous reset
            syncd <= 1'b0;      								//resetting the synced register to 0
            dmeta <= 1'b0;      								//resetting dmeta register to 0
        else
            dmeta <= d_in;      								//passing d_in to dmeta
            syncd <= dmeta;     								//passing dmeta to syncd
    end

endmodule
