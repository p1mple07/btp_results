module mux_synch (

input [7:0] data_in,   
input req,       
input dst_clk,     
input src_clk,     
input nrst,     
output reg [7:0] data_out,  
output ack_out ); 


wire syncd_req, anded_req, syncd_ack;
reg syncd_req_1, ack_edge, ack;

                        

nff  req_synch_0 (.d_in(req),.dst_clk(dst_clk),.rst(nrst),.syncd(syncd_req)) ;		//2-flop synchronizer for the enable input

                                
always_ff @(posedge dst_clk)                     					//one clock cycle delayed synced_enable
begin
    syncd_req_1 <= syncd_req;
end

assign anded_req = (!syncd_req_1 && syncd_req);    //posedge detector

	
always_ff @(posedge dst_clk or negedge nrst)
begin                                                   
	if(!nrst)
		data_out <= 1'b0;                //forcing the output data_in to zero when an active-low asynchronous reset is detected.

	else if (anded_req==1'b1)
		data_out <= data_in;                     //latching data_in to data_out when the enable signal is available.
	
	else
		data_out <= data_out;                    //holds the data till next req comes.
end


// acknowledgment signal generation
always_ff@(posedge dst_clk or negedge nrst)
begin
	if(!nrst)
		ack_edge <= 1'b0; 

	else if (anded_req==1'b1)
		ack_edge <= 1'b1;
	
	else
		ack_edge <= 1'b0;
end

//changing the clock domain of the ack signal
nff  enable_synch_1 (.d_in(ack_edge),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack)) ;

//edge detector circuit
assign ack_out = syncd_ack;