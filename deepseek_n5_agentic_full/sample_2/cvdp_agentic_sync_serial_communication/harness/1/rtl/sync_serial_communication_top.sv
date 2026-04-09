module for the sync_serial_communication system
module sync_serial_communication_top (
    // Inputs
    clk,
    reset_n,
    sel,
    data_in,
    // Outputs
    data_out,
    done,
    gray_out
);

    // Instantiate the top-level components
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