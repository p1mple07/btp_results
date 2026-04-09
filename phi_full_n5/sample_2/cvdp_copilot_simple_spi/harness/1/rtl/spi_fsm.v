
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

    // State register
    reg [1:0] state, next_state;
    
    // Functional blocks
    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b) begin
            state <= 2'b00; // Reset to Idle state
            o_spi_cs_b <= 1; // SPI chip select active
            o_spi_clk <= 0;  // SPI clock inactive
            o_spi_data <= 0; // SPI data output inactive
            o_bits_left <= 5'b10_1000; // Initial bits left
            o_done <= 0;     // Done output inactive
            o_fsm_state <= 2'b00; // FSM state Idle
        end else begin
            state <= next_state;
        end
    end
    
    // State transition logic
    always @(state, i_enable, i_fault, i_clear, i_data_in) begin
        case (state)
            2'b00: begin // Idle
                if (i_enable) begin
                    next_state <= 2'b01; // Transmit
                    o_spi_cs_b <= 0; // SPI chip select active
                end
                else begin
                    next_state <= 2'b00; // Remain in Idle
                end
            end
            2'b01: begin // Transmit
                if (o_bits_left[4:0] == 5'b00000) begin
                    next_state <= 2'b10; // Clock Toggle
                    o_spi_data <= i_data_in[15]; // Load MSB
                    o_spi_clk <= ~o_spi_clk; // Toggle SPI clock
                    o_bits_left <= o_bits_left - 5'b1; // Decrement bits left
                    o_done <= 1; // Done pulse
                end
                else begin
                    next_state <= 2'b01; // Continue Transmit
                end
            end
            2'b10: begin // Clock Toggle
                if (o_bits_left[4:0] == 5'b00000) begin
                    next_state <= 2'b00; // Idle
                    o_spi_cs_b <= 1; // SPI chip select inactive
                    o_spi_clk <= 0; // SPI clock inactive
                    o_spi_data <= 0; // SPI data output inactive
                    o_bits_left <= 5'b10_1000; // Reset bits left
                    o_done <= 0; // Done output inactive
                    o_fsm_state <= 2'b00; // FSM state Idle
                end
                else begin
                    next_state <= 2'b11; // Error
                end
            end
            2'b11: begin // Error
                o_spi_cs_b <= 1; // SPI chip select active
                o_spi_clk <= 0; // SPI clock inactive
                o_spi_data <= 0; // SPI data output inactive
                o_bits_left <= 5'b10_1000; // Reset bits left
                o_done <= 0; // Done output inactive
                o_fsm_state <= 2'b11; // FSM state Error
            end
            default: begin
                next_state <= 2'b00; // Reset to Idle
            end
        end
    end
    
    // Clear logic
    always @(i_clear) begin
        state <= 2'b00; // Force FSM to Idle
        o_spi_cs_b <= 1; // SPI chip select active
        o_spi_clk <= 0; // SPI clock inactive
        o_spi_data <= 0; // SPI data output inactive
        o_bits_left <= 5'b10_1000; // Reset bits left
        o_done <= 0; // Done output inactive
        o_fsm_state <= 2'b00; // FSM state Idle
    end
    
endmodule
