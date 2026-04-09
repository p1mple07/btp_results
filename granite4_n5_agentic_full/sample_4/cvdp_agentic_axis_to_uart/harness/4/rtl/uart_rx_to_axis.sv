module uart_rx_to_axis #(
    parameter CLK_FREQ = 100 MHz,
    parameter BIT_RATE = 115200 bps,
    parameter BIT_PER_WORD = 8 bits,
    parameter PARITY_BIT = 1,
    parameter STOP_BITS_NUM = 1
) (
    // Inputs
    input wire clk,
    input wire rx,
    // Outputs
    output reg tvalid,
    output reg [7:0] tdata,
    output reg tuser
);

//... (rest of the code goes here)

endmodule