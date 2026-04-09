module mux_synch (

    input  [7:0] data_in,    // asynchronous data input
    input        req,        // indicating that data is available at the data_in input
    input        dst_clk,    // destination clock
    input        src_clk,    // source clock
    input        nrst,       // asynchronous reset 
    output reg [7:0] data_out, // synchronized version of data_in to the destination clock domain
    output        ack_out     // acknowledgment signal transmitted back to the source domain
);

    wire         syncd_req;
    wire         anded_req;
    wire         syncd_ack;
    reg          syncd_req_1;
    reg          ack;         // one-cycle pulse generated in destination domain
    reg          ack_stretched; // pulse stretcher: holds the ack pulse for an extra cycle

    // Synchronize the req signal from source to destination domain
    nff req_synch_0 (
        .d_in     (req),
        .dst_clk  (dst_clk),
        .rst      (nrst),
        .syncd    (syncd_req)
    );

    // One clock cycle delay of the synchronized req signal
    always_ff @(posedge dst_clk) begin
        syncd_req_1 <= syncd_req;
    end

    // Generate a pulse (posedge) when the req signal transitions
    assign anded_req = (!syncd_req_1 && syncd_req);

    // Latch data_in to data_out on the rising edge of the pulse
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst)
            data_out <= 8'b0;
        else if (anded_req == 1'b1)
            data_out <= data_in;
        else
            data_out <= data_out;
    end

    // Generate a one-cycle ack pulse in the destination domain
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst)
            ack <= 1'b0;
        else if (anded_req == 1'b1)
            ack <= 1'b1;
        else
            ack <= 1'b0;
    end

    // Pulse stretcher: Extend the ack pulse for one extra destination clock cycle.
    // This ensures that when the ack pulse crosses to the source domain,
    // it overlaps at least one rising edge of src_clk.
    always_ff @(posedge dst_clk or negedge nrst) begin
        if (!nrst)
            ack_stretched <= 1'b0;
        else if (anded_req == 1'b1)
            ack_stretched <= 1'b1;
        else if (ack_stretched)
            ack_stretched <= 1'b1; // hold for an extra cycle
        else
            ack_stretched <= 1'b0;
    end

    // Synchronize the stretched ack pulse from destination domain to source domain
    nff enable_synch_1 (
        .d_in     (ack_stretched),
        .dst_clk  (src_clk),
        .rst      (nrst),
        .syncd    (syncd_ack)
    );

    assign ack_out = syncd_ack;

endmodule

module nff (
    input  d_in,       // input data that needs to be synchronized to the dst_clk domain.
    input  dst_clk,    // destination domain clock.
    input  rst,        // asynchronous active-low reset
    output reg syncd   // synced output, which is a 2-clock-cycle delayed version of d_in.
);
    reg dmeta;

    always @(posedge dst_clk or negedge rst)  
    begin
        if (!rst) begin
            syncd   <= 1'b0;
            dmeta   <= 1'b0;
        end else begin
            dmeta   <= d_in;
            syncd   <= dmeta;
        end
    end

endmodule