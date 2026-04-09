
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

    // Internal signals
    reg [1:0] state_reg = 2'b00; // FSM state register
    reg o_spi_clk_reg = 1'b0;    // Internal SPI clock signal

    // Always block for combinational logic
    always @(posedge i_clk or posedge i_rst_b) begin
        if (i_rst_b) begin
            state_reg <= 2'b00;
            o_spi_clk_reg <= 1'b0;
            o_spi_cs_b <= 1'b1;
            o_spi_data <= 16'h0000_0000;
            o_bits_left <= 5'b10100;
            o_done <= 1'b0;
            o_fsm_state <= 2'b00;
        end else begin
            case (state_reg)
                2'b00: begin
                    if (i_enable) begin
                        o_spi_cs_b <= 1'b0;
                        state_reg <= 2'b01;
                    end else begin
                        state_reg <= 2'b00;
                    end
                end
                2'b01: begin
                    o_spi_data <= i_data_in[15];
                    o_bits_left <= o_bits_left - 1;
                    if (o_bits_left == 5'b00010) begin
                        state_reg <= 2'b10;
                        o_spi_clk_reg <= ~o_spi_clk_reg;
                    end
                end
                2'b10: begin
                    if (o_bits_left == 5'b00000) begin
                        o_done <= 1'b1;
                        state_reg <= 2'b00;
                    end else begin
                        state_reg <= 2'b10;
                    end
                end
                2'b11: begin
                    o_spi_cs_b <= 1'b0;
                    o_spi_clk_reg <= 1'b0;
                    o_spi_data <= 16'h0000_0000;
                    o_bits_left <= 5'b10100;
                    o_done <= 1'b0;
                    o_fsm_state <= 2'b11;
                end
            endcase
        end
    end

endmodule
