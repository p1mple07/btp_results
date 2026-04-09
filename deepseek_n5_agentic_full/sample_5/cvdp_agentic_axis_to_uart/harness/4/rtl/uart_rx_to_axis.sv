module uart_rx_to_axis(
    parameter clocks CLK_FREQ = 100_000_000,
    parameter bits_per_second BIT_RATE = 115200,
    parameter bits data_width = 8,
    parameter parity select PARITY_BIT = 0,
    parameter stop_bits num = 1
);

    // Parameters for FSM states
    parameter idling_state = 0;
    parameter start_bit_state = 1;
    parameter data_state = 2;
    parameter parity_state = 3;
    parameter stop_one_state = 4;
    parameter stop_two_state = 5;
    parameter out_rdy_state = 6;

    // State variable
    reg state = idling_state;

    // FSM control logic
    case(state)
        idling_state:
            wait for (cycle_per_period - 1) clock_cycles;
            state = start_bit_state;
        start_bit_state:
            // Logic to detect start bit
            if (RX == high) {
                state = data_state;
            }
            else {
                // Handle missed start bit
                state = idling_state;
            }
        data_state:
            // Logic to sample data bits
            if (bit_count >= bit_per_word) {
                if (parity_bit != 0) {
                    // Compute parity
                }
                state = parity_state;
            }
            else {
                bit_count++;
            }
        parity_state:
            // Logic to check parity
            if (parity_error) {
                tuser = 1;
            }
            // Transfer parity bit
            parity_error = false;
            state = stop_one_state;
        stop_one_state:
            // Expecting stop bit 1
            if (RX == high) {
                state = stop_two_state;
                bit_count = 0;
            }
            else {
                state = idling_state;
            }
        stop_two_state:
            // Expecting stop bit 2 (if applicable)
            if (num == 2 && RX == high) {
                state = out_rdy_state;
                bit_count = 0;
            }
            else {
                state = idling_state;
            }
        out_rdy_state:
            // Ready to assert valid
            tvalid = 1;
            // Generate tdata
            // ... (code to construct data based on collected bits)
            state = idling_state;
    endcase;

    // Other necessary components (like counters, FIFO buffers etc.)
    // ... (implementation details)

    initial begin
        // Initialization code
        $init();
    endbegin

endmodule