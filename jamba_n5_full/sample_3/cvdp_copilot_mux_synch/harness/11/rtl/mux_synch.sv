module mux_synch (
    input [7:0] data_in,   			// asynchronous data input
    input req,                  		// indicates data availability
    input dst_clk,                 		// destination clock
    input src_clk,                 		// source clock
    input nrst,                    		// asynchronous reset
    output reg [7:0] data_out,              // synchronized data output
    output ack_out ); 		

    wire syncd_req, anded_req, syncd_ack;
    reg syncd_req_1, ack;

    nff  req_synch_0 (.d_in(req),.dst_clk(dst_clk),.rst(nrst),.syncd(syncd_req));

    always_ff @(posedge dst_clk)
        begin
            syncd_req_1 <= syncd_req;
        end

    assign anded_req = (!syncd_req_1 && syncd_req);

    always_ff @(posedge dst_clk or negedge nrst)
        if(!nrst)
            data_out <= 1'b0;
        else if (anded_req == 1'b1)
            data_out <= data_in;
        else
            data_out <= data_out;

    // Acknowledge generation
    always_ff @(posedge dst_clk or negedge nrst)
        begin
            if(!nrst)
                ack <= 1'b0;
            else if (anded_req == 1'b1)
                ack <= 1'b1;
            else
                ack <= 1'b0;
        end

    // Synchronize acknowledgment to source domain
    nff  enable_synch_1 (.d_in(ack),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack));

    ack_out = syncd_ack;

endmodule
