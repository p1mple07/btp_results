module mux_synch (

    input [7:0] data_in,
    input req,
    input dst_clk,
    input src_clk,
    input nrst,
    output reg [7:0] data_out
);

    two_flop_sync sync (
        .d_in(data_in),
        .d_out(data_out),
        .clk(dst_clk),
        .rst(~src_clk)
    );

endmodule
