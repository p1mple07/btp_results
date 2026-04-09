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

    // FSM state encoding
    localparam IDLE       = 2'b00;
    localparam TRANSMIT   = 2'b01;
    localparam CLOCK_TOGG = 2'b10;
    localparam ERROR      = 2'b11;
    
    // Internal registers
    reg [1:0] state;
    reg [15:0] shift_reg;
    reg [4:0] bits_left;
    reg done_reg;
    reg spi_clk_reg;
    
    // Synchronous state machine and internal register updates
    always @(posedge i_clk or negedge i_rst_b) begin
        if (!i_rst_b) begin
            state       <= IDLE;
            shift_reg   <= 16'd0;
            bits_left   <= 5'd16;  // 16 bits remaining (0x10)
            done_reg    <= 1'b0;
            spi_clk_reg <= 1'b0;
        end 
        else begin
            // i_clear takes highest priority: force idle
            if (i_clear) begin
                state       <= IDLE;
                shift_reg   <= 16'd0;
                bits_left   <= 5'd16;
                done_reg    <= 1'b0;
                spi_clk_reg <= 1'b0;
            end 
            // Fault condition: enter error state
            else if (i_fault) begin
                state       <= ERROR;
                shift_reg   <= 16'd0;
                bits_left   <= 5'd10;  // Safe default in error state
                done_reg    <= 1'b0;
                spi_clk_reg <= 1'b0;
            end 
            // If i_enable is deasserted, go to idle
            else if (!i_enable) begin
                state       <= IDLE;
                shift_reg   <= 16'd0;
                bits_left   <= 5'd16;
                done_reg    <= 1'b0;
                spi_clk_reg <= 1'b0;
            end 
            else begin
                case (state)
                    IDLE: begin
                        // Wait for enable to start transmission
                        if (i_enable) begin
                            shift_reg   <= i_data_in;  // Load input data
                            bits_left   <= 5'd16;       // Reset bit counter
                            state       <= TRANSMIT;
                        end
                    end
                    TRANSMIT: begin
                        // In Transmit state, output the MSB of the shift register.
                        // Transition to CLOCK_TOGG to toggle the clock and shift the data.
                        state <= CLOCK_TOGG;
                    end
                    CLOCK_TOGG: begin
                        // Toggle the SPI clock signal
                        spi_clk_reg <= ~spi_clk_reg;
                        // Shift the data register right by one bit
                        shift_reg   <= shift_reg >> 1;
                        // Decrement the bit counter
                        bits_left   <= bits_left - 1;
                        // If this was the last bit, go back to idle and assert done pulse
                        if (bits_left == 1) begin
                            state  <= IDLE;
                            done_reg <= 1'b1;
                        end 
                        else begin
                            state <= TRANSMIT;
                        end
                    end
                    ERROR: begin
                        // Remain in ERROR until cleared
                        if (i_clear) begin
                            state       <= IDLE;
                            shift_reg   <= 16'd0;
                            bits_left   <= 5'd16;
                            done_reg    <= 1'b0;
                            spi_clk_reg <= 1'b0;
                        end
                    end
                    default: begin
                        state <= IDLE;
                    end
                endcase
            end
        end
    end
    
    // Output logic based on current state
    always @(*) begin
        case (state)
            IDLE: begin
                o_spi_cs_b = 1'b1;  // Chip select inactive (high)
                o_spi_clk  = 1'b0;
                o_spi_data = 1'b0;
            end
            TRANSMIT, CLOCK_TOGG: begin
                o_spi_cs_b = 1'b0;  // Activate chip select during transmission
                o_spi_clk  = spi_clk_reg;
                o_spi_data = shift_reg[15];  // Output MSB of data register
            end
            ERROR: begin
                o_spi_cs_b = 1'b1;  // Safe default: chip select inactive
                o_spi_clk  = 1'b0;
                o_spi_data = 1'b0;
            end
            default: begin
                o_spi_cs_b = 1'b1;
                o_spi_clk  = 1'b0;
                o_spi_data = 1'b0;
            end
        endcase
    end
    
    // Drive remaining outputs
    assign o_bits_left = bits_left;
    assign o_done      = done_reg;
    assign o_fsm_state = state;
    
endmodule