module mux_synch (
    input  [7:0] data_in,    // asynchronous data input
    input        req,        // indicates that data is available at the data_in input
    input        dst_clk,    // destination clock (sampling clock for synchronization)
    input        src_clk,    // source clock (provided for interface completeness)
    input        nrst,       // asynchronous active-low reset
    output reg [7:0] data_out // synchronized version of data_in to the destination clock domain
);

    //-------------------------------------------------------------------------
    // Synchronize the req signal using a 2-flop synchronizer (nff module)
    //-------------------------------------------------------------------------
    wire req_sync;
    nff req_sync_inst (
        .d_in  (req),
        .dst_clk(dst_clk),
        .rst   (nrst),
        .syncd (req_sync)
    );

    //-------------------------------------------------------------------------
    // Data path synchronization: Pipeline the data through three stages
    // to ensure that the asynchronous data_in is stable for at least three
    // destination clock cycles before being passed to data_out.
    //-------------------------------------------------------------------------
    reg [7:0] data_sync_stage1;
    reg [7:0] data_sync_stage2;
    reg [7:0] data_sync_stage3;

    always @(posedge dst_clk or negedge nrst) begin
        if (!nrst) begin
            data_sync_stage1 <= 8'b0;
            data_sync_stage2 <= 8'b0;
            data_sync_stage3 <= 8'b0;
            data_out         <= 8'b0;
        end else begin
            // Capture data_in only when the synchronized req signal is asserted.
            if (req_sync)
                data_sync_stage1 <= data_in;
                
            data_sync_stage2 <= data_sync_stage1;
            data_sync_stage3 <= data_sync_stage2;
            data_out         <= data_sync_stage3;
        end
    end

endmodule

//-------------------------------------------------------------------------
// Module: nff
// Description: A 2-flop synchronizer that safely transfers an asynchronous
//              signal (d_in) into the destination clock domain.
//              Two sequential flip-flops are used to minimize metastability.
//-------------------------------------------------------------------------
module nff (
    input  d_in,       // asynchronous signal to be synchronized
    input  dst_clk,    // destination clock
    input  rst,        // asynchronous active-low reset
    output reg syncd   // synchronized output (2-clock-cycle delayed version of d_in)
);

    // First flip-flop in the synchronizer chain
    reg d_temp;
    always @(posedge dst_clk or negedge rst) begin
        if (!rst)
            d_temp <= 1'b0;
        else
            d_temp <= d_in;
    end

    // Second flip-flop in the synchronizer chain
    always @(posedge dst_clk or negedge rst) begin
        if (!rst)
            syncd <= 1'b0;
        else
            syncd <= d_temp;
    end

endmodule