module uart_rx_to_axis #(
    parameter int CLK_FREQ = 100 MHz,
    parameter int BIT_RATE = 115200 bps,
    parameter int BIT_PER_WORD = 8 bits,
    parameter int PARITY_BIT = 0 (no parity),
    parameter int STOP_BITS_NUM = 1 (one stop bit)
)(
    // RTL signals
    input logic rx,
    output logic [7:0] tdata,
    output logic tuser,
    output logic tvalid
);

// Define necessary internal signals and variables here

// Define the FSM states and their associated logic here.

endmodule