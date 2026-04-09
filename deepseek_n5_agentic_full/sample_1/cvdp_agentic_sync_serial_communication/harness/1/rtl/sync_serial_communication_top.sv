module for the sync_serial_communication design
module sync_serial_communication_top (

    // Signals from the design
    input clock,
    input reset_n,
    input [2:0] sel,
    input [63:0] data_in,
    output [63:0] data_out,
    output done,
    output [63:0] gray_out

);

    // Instantiate the components
    sync_serial_communication_tx_rx uut (
        .clk(clk),
        .reset_n(reset_n),
        .sel(sel),
        .data_in(data_in),
        .data_out(data_out),
        .done(done),
        .gray_out(gray_out)
    );

endmodule