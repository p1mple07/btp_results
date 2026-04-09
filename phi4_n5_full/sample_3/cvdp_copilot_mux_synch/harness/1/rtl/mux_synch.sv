module mux_synch (
    input  [7:0] data_in,    // asynchronous data input
    input        req,        // indicates that valid data is available at data_in
    input        dst_clk,    // destination clock domain
    input        src_clk,    // source clock domain (not used in this design)
    input        nrst,       // asynchronous active-low reset
    output reg [7:0] data_out // synchronized version of data_in in the destination clock domain
);

    // Synchronize the req signal using a 2-flop synchronizer (nff module)
    wire sync_req;
    nff req_sync (
        .d_in  (req),
        .dst_clk(dst_clk),
        .rst   (nrst),
        .syncd (sync_req)
    );

    // Pipeline registers for data synchronization.
    // The input data is sampled when sync_req is high; otherwise, 0 is passed.
    // A three-stage pipeline is used to meet the requirement that data remains stable for at least three destination clock cycles.
    reg [7:0] data_sync0, data_sync1, data_sync2;

    always @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            data_sync0 <= 8'b0;
            data_sync1 <= 8'b0;
            data_sync2 <= 8'b0;
        end else begin
            // Sample data_in when sync_req is high; else pass 0.
            data_sync0 <= (sync_req) ? data_in : 8'b0;
            data_sync1 <= data_sync0;
            data_sync2 <= data_sync1;
        end
    end

    // Drive the final output from the last stage of the pipeline.
    always @(posedge dst_clk or negedge nrst) begin
        if (!nrst)
            data_out <= 8'b0;
        else
            data_out <= data_sync2;
    end

endmodule

module nff (
    input  d_in,    // asynchronous input signal to be synchronized
    input  dst_clk, // destination clock domain
    input  rst,     // asynchronous active-low reset
    output reg syncd // synchronized output (2-clock-cycle delayed version of d_in)
);

    // Two-stage flip-flop synchronizer to minimize metastability.
    reg d_in_ff;

    always @(posedge dst_clk or negedge rst) begin
        if (!rst) begin
            d_in_ff  <= 1'b0;
            syncd    <= 1'b0;
        end else begin
            d_in_ff  <= d_in;
            syncd    <= d_in_ff;
        end
    end

endmodule