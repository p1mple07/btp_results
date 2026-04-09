module spi_fsm (
    input  wire         i_clk,       // System clock
    input  wire         i_rst_b,     // Active-low async reset
    input  wire [15:0]  i_data_in,   // Parallel 16-bit data to transmit
    input  wire         i_enable,    // Enable block
    input  wire         i_fault,     // Fault indicator
    input  wire         i_clear,     // Forces FSM to clear/idle
    
    output reg          o_spi_cs_b,  // SPI chip select (active-low)
    output reg          o_spi_clk,   // SPI clock
    output reg          o_spi_data,  // Serialized SPI data out
    output reg [4:0]    o_bits_left, // Bits left to transmit
    output reg          o_done,      // Single-cycle pulse when done or error
    output reg [1:0]    o_fsm_state  // FSM state for external monitoring
);

    // State variables
    reg state = 00;  // 00:Idle, 01:Transmit, 10:Clock Toggle, 11:Error
    reg [1:0] next_state;
    reg [15:0] received_data = 0;
    reg [1:0] clock_state = 0;

    // Initialize outputs on reset
    always_comb begin
        if (i_rst_b) begin
            state = 00;
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 10;
            o_done = 0;
            o_fsm_state = 00;
        end
    end

    // Processing logic
    always_ff @posedge i_enable or posedge i_clear or posedge i_fault begin
        case (state)
            00: // Idle
                if (i_enable) begin
                    o_fsm_state = 00;
                    o_spi_cs_b = 1;
                    o_spi_clk = 0;
                    o_spi_data = 0;
                    o_bits_left = 10;
                    // Start receiving data
                    received_data = 0;
                    // Set clock_state to inactive (0)
                    clock_state = 0;
                end else if (i_clear) begin
                    // Transition to idle
                    next_state = 00;
                end else if (i_fault) begin
                    // Transition to error
                    next_state = 11;
                end
                // No change to state
                next_state = state;
            01: // Transmit
                if (clock_state == 0) begin
                    // Load new data
                    received_data = i_data_in[15:0];
                    // Start transmitting
                    o_spi_cs_b = 0;
                    o_spi_clk = 1;
                    o_spi_data = 0;
                    o_bits_left = 10;
                    // Toggle clock_state
                    clock_state = 1;
                    // Update state
                    next_state = state;
                else begin
                    // Shift data
                    received_data = received_data << 1;
                    o_spi_data = received_data & 0;
                    o_bits_left = o_bits_left - 1;
                    // If more bits to send
                    if (o_bits_left > 0) begin
                        // Keep state as Transmit
                        next_state = state;
                    else begin
                        // Transition to Clock Toggle
                        next_state = 10;
                    end
                end
            10: // Clock Toggle
                if (clock_state == 1) begin
                    // Latch data
                    o_spi_data = received_data;
                    // Assert done signal
                    o_done = 1;
                    // Transition to idle
                    next_state = 00;
                else begin
                    // Keep state as Clock Toggle
                    next_state = state;
                end
                // Toggle clock_state
                clock_state = not clock_state;
            11: // Error
                // Drive outputs to safe values
                o_spi_cs_b = 1;
                o_spi_clk = 0;
                o_spi_data = 0;
                o_bits_left = 10;
                o_done = 0;
                // Stay in error state
                next_state = state;
        endcase
    end

    // Update state
    state = next_state;
endmodule