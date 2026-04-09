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
reg          fsm_state = 0;          // 00:Idle, 01:Transmit, 10:ClockToggle, 11:Error
reg          data_reg;
reg [4:0]     bits_left = 0b10000; // Initialize to 16 bits remaining
reg          clock En = 1;          // Enable clock for state transitions

// Data handling
always @(i_data_in, i_enable, i_fault, i_clear) begin
    if (i_enable) begin
        // Initialize on first enable
        if (fsm_state == 0) begin
            o_spi_cs_b = 1;
            o_spi_clk = 0;
            o_spi_data = 0;
            o_bits_left = 0b10000;
            o_fsm_state = 0b00;
        end
    end
end

always @(i_data_in, i_enable, i_fault, i_clear) begin
    // Transmit state
    if (fsm_state == 0b01) begin
        data_reg = i_data_in[15];
        fsm_state = 0b10;
        o_spi_cs_b = 0;
        o_spi_clk = 1;
        o_spi_data = 0;
        bits_left = 0b10000 - 1;
    end
    // Clock toggle state
    else if (fsm_state == 0b10) begin
        if (o_spi_clk) begin
            o_spi_data = data_reg;
            o_bits_left = 0b10000 - bits_left - 1;
            fsm_state = 0b00;
            o_done = 1;
        end
        o_spi_clk = ~o_spi_clk;
    end
    // Error state
    else if (fsm_state == 0b11) begin
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 0b10000;
        o_fsm_state = 0b11;
    end
end

// Clear signal handling
always @* begin
    if (i_clear) begin
        fsm_state = 0b00;
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 0b10000;
        o_fsm_state = 0b00;
        o_done = 0;
    end
end

// Reset signal handling
always @* begin
    if (i_rst_b) begin
        fsm_state = 0b00;
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 0b10000;
        o_fsm_state = 0b00;
        o_done = 0;
    end
end

endmodule