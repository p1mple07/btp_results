module axis_to_uart_tx #(
    parameter CLK_FREQ = 100000000,      // default 100 MHz
    parameter BIT_RATE = 115200,           // default 115200 bps
    parameter BIT_PER_WORD = 8,            // default 8 data bits
    parameter PARITY_BIT = 0,              // default 0 (no parity)
    parameter STOP_BITS_NUM = 1             // default 1 stop bit
)(
    input aclk,
    input aresetn,
    input tdata,
    input tvalid,
    input tready,
    output reg tx_data,
    output reg tx_ready
);
