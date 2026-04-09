module uart_rx_to_axis #(
    parameter CLK_FREQ = 100 MHz.
    parameter BIT_RATE = 115200 bps.
    parameter BIT_PER_WORD = 8 bits.
    parameter PARITY_BIT = 0 (no parity).
    parameter STOP_BITS_NUM = 1 (one stop bit).
) (
    input wire rx, // Serial UART input.

    output reg tdata, // Parallel data output.

    output reg tuser, // Parity error indicator.

    output reg tvalid, // Valid data word indicator.

    //... (other inputs and outputs as specified in the specs).
) begin
    //... (internal variables and signals).

    //... (FSM and other internal logic).

    always @(posedge clk) begin
        //... (FSM transition logic).

        //... (FSM transition logic).

        //... (FSM state machine implementation).

        //... (FSM state machine implementation).
    end
endmodule