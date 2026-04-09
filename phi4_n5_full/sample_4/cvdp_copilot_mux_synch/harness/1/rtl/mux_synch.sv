module mux_synch (
    input  [7:0] data_in,   // asynchronous data input
    input        req,       // indicates that data is available at data_in
    input        dst_clk,   // destination clock (synchronization occurs on rising edge)
    input        src_clk,   // source clock (not used in dst_clk domain operations)
    input        nrst,      // active-low asynchronous reset
    output reg [7:0] data_out // synchronized version of data_in in the destination domain
);

    // Two-flop synchronizer for the req signal from the source domain.
    reg req_sync0, req_sync1;
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            req_sync0 <= 1'b0;
            req_sync1 <= 1'b0;
        end else begin
            req_sync0 <= req;
            req_sync1 <= req_sync0;
        end
    end

    // Pipeline registers to capture and delay the data_in signal.
    // The multiplexer selects between the new data_in (when req_sync1 is high)
    // and the previous value (when no new data is available).
    // This three-stage pipeline ensures that the input data remains stable for at least three dst_clk cycles.
    reg [7:0] data_pipe0, data_pipe1, data_pipe2;
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            data_pipe0 <= 8'b0;
            data_pipe1 <= 8'b0;
            data_pipe2 <= 8'b0;
        end else begin
            // If a synchronized request is detected, load the new data_in.
            data_pipe0 <= (req_sync1) ? data_in : data_pipe0;
            data_pipe1 <= data_pipe0;
            data_pipe2 <= data_pipe1;
        end
    end

    // Drive the output from the last stage of the pipeline.
    always_comb begin
        data_out = data_pipe2;
    end

endmodule

module nff (
    input  d_in,       // asynchronous signal to be synchronized
    input  dst_clk,    // destination clock
    input  rst,        // active-low asynchronous reset
    output reg syncd   // synchronized output (2-clock-cycle delayed version of d_in)
);

    // Two-flop synchronizer for d_in to mitigate metastability.
    reg d_in_sync;
    always_ff @(posedge dst_clk or negedge rst) begin
        if (!rst) begin
            d_in_sync <= 1'b0;
            syncd     <= 1'b0;
        end else begin
            d_in_sync <= d_in;
            syncd     <= d_in_sync;
        end
    end

endmodule