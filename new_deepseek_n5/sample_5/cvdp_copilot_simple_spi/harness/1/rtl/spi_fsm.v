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

always @* begin
    case (o_fsm_state)
        2'b00: // Idle
            if (i_enable) 
                o_fsm_state = 2'b01;
            else 
                o_spi_cs_b = 1;
                o_spi_clk = 0;
                o_spi_data = 0;
                o_bits_left = 16;
                o_done = 0;
        2'b01: // Transmit
            if (i_enable) 
                o_fsm_state = 2'b10;
            else 
                o_spi_cs_b = 1;
                o_spi_clk = 0;
                o_spi_data = 0;
                o_bits_left = 16;
                o_done = 0;
        2'b10: // Clock Toggle
            if (i_enable) 
                o_fsm_state = 2'b00;
                o_spi_data = 0;
                o_bits_left -= 1;
                o_spi_clk = !o_spi_clk;
            else 
                o_spi_cs_b = 1;
                o_spi_clk = 0;
                o_spi_data = 0;
                o_bits_left = 16;
                o_done = 0;
        2'b11: // Error
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 16;
            o_done = 0;
    endcase
endmodule