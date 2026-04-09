module uart_rx_to_axis #(
    parameter int CLK_FREQ = 100 MHz,
    parameter int BIT_RATE = 115200 bps,
    parameter int BIT_PER_WORD = 8,
    parameter int PARITY_BIT = 0, // 0 for no parity, 1 for odd parity, 2 for even parity
    parameter int STOP_BITS_NUM = 1 // 1 for 1 stop bit, 2 for 2 stop bits
) (
    input wire rx,
    output reg tdata,
    output reg tuser,
    output reg tvalid
);

reg [BIT_PER_WORD-1:0] data_shift_reg;
reg [8*BIT_PER_WORD-1:0] data_shift_reg_next;
reg [31:0] clk_counter;
reg [7:0] bit_count;

//... (implementation of the module as described in the specification.)

endmodule