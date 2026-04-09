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

    reg fsm_state = 0; // Idle state (00)

    always @* begin
        if (i_rst_b) begin
            fsm_state = 0; // Idle
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 16;
            o_done = 0;
            o_fsm_state = 0;
        end else if (i_enable) begin
            case (fsm_state)
                0: begin // Idle
                    o_spi_cs_b = 0;
                    o_spi_clk = 0;
                    o_spi_data = 0;
                    o_bits_left = 16;
                    fsm_state = 1; // Transmit
                end
                1: begin // Transmit
                    o_spi_cs_b = 0;
                    o_spi_data = (i_data_in[15]);
                    o_bits_left = 15;
                    fsm_state = 2; // Clock Toggle
                    o_spi_clk = 1;
                end
                2: begin // Clock Toggle
                    o_spi_data = o_spi_data & 1;
                    o_bits_left = o_bits_left - 1;
                    fsm_state = (o_bits_left == 0) ? 0 : 3;
                    o_spi_clk = ~o_spi_clk;
                end
                3: begin // Error
                    o_spi_cs_b = 1;
                    o_spi_clk = 0;
                    o_spi_data = 0;
                    o_bits_left = 10;
                    fsm_state = 3;
                end
            endcase
        end else if (i_fault) begin
            fsm_state = 3; // Error
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 10;
            o_fsm_state = 3;
        end else if (i_clear) begin
            fsm_state = 0; // Idle
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 16;
            o_fsm_state = 0;
        end
    end

    // Set done when transmitting is complete
    if (o_bits_left == 0 && fsm_state == 0) begin
        o_done = 1;
    else
        o_done = 0;
    end

    // Set done when error state
    if (fsm_state == 3) begin
        o_done = 1;
    end

    // Set done when in Done state
    if (o_fsm_state == 2) begin
        o_done = 1;
    end

endmodule