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
    reg syncd_req_1;

    // Synchronizer for the req signal into the destination domain
    nff req_synch_0 (
        .d_in(req),
        .dst_clk(dst_clk),
        .rst(nrst),
        .syncd(syncd_req)
    );

    // One clock cycle delay for the synchronized req signal
    always_ff @(posedge dst_clk) begin
        syncd_req_1 <= syncd_req;
    end

    // Edge detector: generate a pulse when req transitions from 0 to 1
    assign anded_req = (!syncd_req_1 && syncd_req);

    // Data sampling logic: latch data_in when the pulse is detected
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst)
            data_out <= 8'b0;
        else if (anded_req)
            data_out <= data_in;
        else
            data_out <= data_out;
    end

    // Acknowledgment generation with pulse stretching to ensure proper sampling in the source domain.
    // The ack pulse is stretched to cover two consecutive clock cycles in the destination domain.
    reg ack;
    reg ack_stretch; // used to stretch the ack pulse

    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            ack      <= 1'b0;
            ack_stretch <= 1'b0;
        end
        else if (anded_req) begin
            ack      <= 1'b1;
            ack_stretch <= 1'b1;
        end
        else if (ack_stretch) begin
            ack      <= 1'b1;
            ack_stretch <= 1'b0;
        end
        else begin
            ack      <= 1'b0;
            ack_stretch <= 1'b0;
        end
    end

    // Synchronize the stretched ack signal back to the source clock domain
    nff enable_synch_1 (
        .d_in(ack),
        .dst_clk(src_clk),
        .rst(nrst),
        .syncd(syncd_ack)
    );

    // Drive the acknowledgment output with the synchronized signal
    assign ack_out = syncd_ack;

endmodule

module nff (
    input d_in,   									// input data to be synchronized to the dst_clk domain
    input dst_clk,     								// destination clock
    input rst,         								// asynchronous active-low reset
    output reg syncd 								// synchronized output (2-clock-cycle delayed version of d_in)
);

    reg dmeta;             								// intermediate register

    always @(posedge dst_clk or negedge rst) begin
        if (!rst) begin
            syncd   <= 1'b0;
            dmeta   <= 1'b0;
        end
        else begin
            dmeta   <= d_in;
            syncd   <= dmeta;
        end
    end

endmodule