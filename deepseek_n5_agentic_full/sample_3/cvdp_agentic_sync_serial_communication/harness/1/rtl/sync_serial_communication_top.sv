module sync_serial_communication_top(
    parameter clock,
    parameter reset_n,
    parameter sel,
    parameter data_in,
    output data_out,
    output gray_out
);

// Instantiate tx_block
sync_serial_communication_tx_rx uut_tx (
    .clk(clock),
    .reset_n(reset_n),
    .sel(sel),
    .data_in(data_in),
    .data_out(),
    .done(),
    .gray_out()
);

// Instantiate rx_block
sync_serial_communication_tx_rx uut_rx (
    .clk(clock),
    .reset_n(reset_n),
    .sel(sel),
    .data_in(),
    .data_out(data_out),
    .done(),
    .gray_out(gray_out)
);

// Instantiate binary_to_gray_conversion
binary_to_gray_conversion uut_gray (
    .data(data_out),
    .gray(gray_out)
);

// Initialize top-level blocks
initial begin
    // Enable transmitter after reset
    reset_n = 0;
    initial await uut_tx.reset_n;
    
    // Start transmitter
    reset_n = 1;
    initial wait uut_tx.done;

    // Start receiver
    reset_n = 0;
    initial wait uut_rx.reset_n;

    // Drive some test patterns
    drive_byte();
    drive_half_word();
    drive_word();
    double_word();
end

// Add assertions for testing
static begin
    $display("Test complete.");
    $finish();
end

endmodule