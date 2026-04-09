module mux_synch (

    input [7:0] data_in,   			//asynchronous data input
    input req,                  		//indicating that data is available at the data_in input
    input dst_clk,                 		//destination clock
    input src_clk,                 		//source clock
    input nrst,                    		//asynchronous reset 
    output reg [7:0] data_out,              //synchronized version of data_in to the destination clock domain
    output reg ack_out ); 		

    wire syncd_req,anded_req,syncd_ack;
    reg syncd_req_1,ack;

    nff req_synch_0 (.d_in(req),.dst_clk(dst_clk),.rst(nrst),.syncd(syncd_req));

    always_ff @(posedge dst_clk or negedge nrst)
    begin
        if(!nrst)
            data_out <= 1'b0;

        else if (anded_req==1'b1)
            data_out <= data_in;

        else
            data_out <= data_out;
    end

    // acknowledgment signal generation
    always_ff@(posedge dst_clk or negedge nrst)
    begin
        if(!nrst)
            ack <= 1'b0;

        else if (anded_req==1'b1)
            ack <= 1'b1;

        else
            ack <= 1'b0;
    end

    // edge detector circuit for ack_out
    assign ack_out = (syncd_ack) & (!src_clk);

endmodule
