module mux_synch (

    input [7:0] data_in,   			//asynchronous data input
    input req,                  		//indicating that data is available at the data_in input
    input dst_clk,                 		//destination clock
    input src_clk,                 		//source clock
    input nrst,                    		//asynchronous reset 
    output reg [7:0] data_out,              //synchronized version of data_in to the destination clock domain
    output ack_out 
);

    wire syncd_req, anded_req, syncd_ack;
    reg syncd_req_1, ack;

    // 2-flop synchronizer for the request signal
    nff req_synch_0 (.d_in(req), .dst_clk(dst_clk), .rst(nrst), .syncd(syncd_req));

    // One clock cycle delay to detect a positive edge
    always_ff @(posedge dst_clk)
    begin
        syncd_req_1 <= syncd_req;
    end

    // Edge detector: high when syncd_req transitions from 0 to 1
    assign anded_req = (!syncd_req_1 && syncd_req);

    // Data capture: latch data_in into data_out when a valid request is detected
    always_ff @(posedge dst_clk or negedge nrst)
    begin
        if (!nrst)
            data_out <= 1'b0;                // force output to zero on reset
        else if (anded_req == 1'b1)
            data_out <= data_in;             // latch data_in to data_out
        else
            data_out <= data_out;            // hold the data until next request
    end

    // Acknowledgment signal generation with pulse stretching in the destination domain.
    // This ensures that the ack pulse is held for two clock cycles so that it is more likely
    // to be captured by the two-flop synchronizer when crossing to the source clock domain.
    always_ff @(posedge dst_clk or negedge nrst)
    begin
        if (!nrst)
            ack <= 1'b0;
        else if (anded_req)
            ack <= 1'b1;
        else if (ack)  // Stretch the ack pulse for an extra clock cycle
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end

    // Synchronize the ack signal back to the source clock domain using a two-flop synchronizer.
    nff enable_synch_1 (.d_in(ack), .dst_clk(src_clk), .rst(nrst), .syncd(syncd_ack));

    // Output the synchronized acknowledgment signal.
    assign ack_out = syncd_ack;

endmodule

// Two-flop synchronizer module
module nff (
    input d_in,   									// input data to be synchronized
    input dst_clk,     								// destination clock
    input rst,         								// asynchronous active-low reset
    output reg syncd 								// synchronized output (2-clock-cycle delayed version of d_in)
);

    reg dmeta;             								// intermediate register

    always @(posedge dst_clk or negedge rst)
    begin
        if (!rst)              								// active-low asynchronous reset
        begin
            syncd <= 1'b0;
            dmeta <= 1'b0;
        end
        else
        begin
            dmeta <= d_in;      								// pass input to intermediate register
            syncd <= dmeta;     								// pass intermediate value to output register
        end
    end

endmodule