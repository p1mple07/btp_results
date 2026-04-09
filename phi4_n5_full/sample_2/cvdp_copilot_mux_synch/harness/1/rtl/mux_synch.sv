module mux_synch (
    input  [7:0] data_in,    // asynchronous data input
    input        req,        // indicates that data is available at data_in
    input        dst_clk,    // destination clock (synchronization occurs on this clock)
    input        src_clk,    // source clock (associated with data_in)
    input        nrst,       // asynchronous active-low reset
    output reg [7:0] data_out // synchronized version of data_in in the destination clock domain
);

    // Synchronize the req signal using a two-flop synchronizer (nff)
    wire req_sync;
    nff req_sync_inst (
        .d_in  (req),
        .dst_clk(dst_clk),
        .rst   (nrst),
        .syncd (req_sync)
    );

    // Pipeline registers for data synchronization (3 stages)
    reg [7:0] data_sync0, data_sync1, data_sync2;

    always @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            data_sync0 <= 8'b0;
            data_sync1 <= 8'b0;
            data_sync2 <= 8'b0;
            data_out   <= 8'b0;
        end else begin
            if (req_sync) begin
                // Capture the asynchronous data_in into the pipeline
                data_sync0 <= data_in;
                data_sync1 <= data_sync0;
                data_sync2 <= data_sync1;
            end
            // Otherwise, hold the previously synchronized value
            data_out <= data_sync2;
        end
    end

endmodule

module nff  (
    input  d_in,    // input data that needs to be synchronized to the dst_clk domain
    input  dst_clk, // destination domain clock
    input  rst,     // asynchronous active-low reset
    output reg syncd // synchronized output (2-clock-cycle delayed version of d_in)
);

    reg sync_reg0, sync_reg1;

    always @(posedge dst_clk or negedge rst) begin
        if (!rst) begin
            sync_reg0 <= 1'b0;
            sync_reg1 <= 1'b0;
            syncd     <= 1'b0;
        end else begin
            sync_reg0 <= d_in;
            sync_reg1 <= sync_reg0;
            syncd     <= sync_reg1;
        end
    end

endmodule