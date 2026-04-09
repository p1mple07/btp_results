module axis_to_uart_tx #(
    parameter integer CLK_FREQ = 100 MHz,
    parameter integer BIT_RATE = 115200 bps,
    parameter integer BIT_PER_WORD = 8,
    parameter paritiy_mode = "none",
    parameter integer STOP_BITS_NUM = 1
)(
    // AXI Stream Ports
    input wire aclk,
    input wire aresetn,
    input wire [7:0] tdata,
    input wire tvalid,
    output reg tready
);

//... (rest of the code goes here)

endmodule