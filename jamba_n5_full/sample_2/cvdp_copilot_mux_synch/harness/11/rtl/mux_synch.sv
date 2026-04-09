module mux_synch (
    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out,
    output ack_out
);

    wire syncd_req, anded_req, syncd_ack;
    reg syncd_req_1, ack;

    // Synchronize data from source to destination
    nff  req_synch_0 (.d_in(req),.dst_clk(dst_clk),.rst(nrst),.syncd(syncd_req));

    // One‑clock‑cycle delayed enable for synchronous sampling
    always_ff @(posedge dst_clk) begin
        syncd_req_1 <= syncd_req;
    end

    assign anded_req = !syncd_req_1 && syncd_req;

    // Force data output on destination clock
    always_ff @(posedge dst_clk or negedge nrst)
        if (!nrst) data_out <= 1'b0;
        else if (anded_req) data_out <= data_in;
        else data_out <= data_out;

    // Generate the acknowledgment in the destination domain
    always_ff @(posedge dst_clk or negedge nrst)
        if (!nrst) ack <= 1'b0;
        else if (anded_req) ack <= 1'b1;
        else ack <= 1'b0;

    // Two‑clock synchronizer for the acknowledgment
    nff  enable_synch_1 (.d_in(ack),.dst_clk(src_clk),.rst(nrst),.syncd(syncd_ack));

    assign ack_out = syncd_ack;

endmodule
