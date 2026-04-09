module mux_synch (
    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out
);

    // Synchronize req using nff with dst_clk
    reg sync_req;
    nff (req, dst_clk, nrst, sync_req);

    // Synchronize data_in using nff with src_clk
    reg sync_data;
    nff (data_in, src_clk, nrst, sync_data);

    // Create the multiplexer
    reg [0:0] f1, f2;
    always dst_clk posedge:
        if (!nrst) begin
            f1 = data_in;
            f2 = f1;
        else
            f1 = f1;
            f2 = f2;
        end
    endalways
    data_out = (sync_req ? f2 : (8'b0000_0000));

    // Alternatively, using a 4:2 demux would require more lines
endmodule

module nff (
    input d_in,
    input clock,
    input rst,
    output reg syncd
);

    reg ff1, ff2;
    always clock posedge:
        if (!rst) begin
            ff1 = d_in;
            ff2 = ff1;
        else
            ff1 = ff1;
            ff2 = ff2;
        end
    endalways
    syncd = ff2;
endmodule