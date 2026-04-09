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
reg state = 0; // 0:Idle, 1:Transmit, 2:ClockToggle, 3:Error

// FSM transitions
always @(i_rst_b or i_enable or i_clear or i_fault) begin
    if (i_rst_b) begin
        state = 0;
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 16;
        o_fsm_state = 0b00;
    end else if (i_enable) begin
        case (state)
            0: state = 1;
            1: state = 2;
            2: state = 0;
            3: state = 0;
        endcase
        o_spi_cs_b = 0;
        o_fsm_state = 0b01;
    end else if (i_clear) begin
        state = 0;
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 16;
        o_fsm_state = 0b00;
    end else if (i_fault) begin
        state = 3;
        o_spi_cs_b = 1;
        o_spi_clk = 0;
        o_spi_data = 0;
        o_bits_left = 16;
        o_fsm_state = 0b11;
    end
end

// Data transmission
always clock begin
    if (state == 1) begin
        o_spi_data = i_data_in[0];
        o_bits_left = 15;
        state = 2;
    end else if (state == 2) begin
        o_spi_data = o_spi_data ^ (i_data_in[1] << 1);
        o_bits_left = o_bits_left - 1;
        if (o_bits_left == 0) begin
            o_spi_data = 0;
            o_bits_left = 16;
            state = 0;
            o_fsm_state = 0b00;
        end
    end
end

// Done signal
always clock begin
    if (o_bits_left == 0) begin
        o_done = 1;
    end else if (o_fsm_state == 0b11) begin
        o_done = 1;
    end else
        o_done = 0;
    end
end

// FSM state output
always @* o_fsm_state = state;
// SPI control signals
always @* o_spi_cs_b = (state & 1) ? 0 : 1;
always @* o_spi_clk = (state & 1) ? 1 : 0;
always @* o_spi_data = (state & 1) ? (i_data_in[0] & 1) : 0;
always @* o_bits_left = (state & 1) ? 16 : (state & 2) ? 8 : (state & 4) ? 4 : (state & 8) ? 2 : 1;
always @* o_done = 0;
always @* o_fsm_state = state;

endmodule