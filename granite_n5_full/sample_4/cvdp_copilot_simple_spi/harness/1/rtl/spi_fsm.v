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

typedef enum logic [1:0] {
    IDLE = 2'd0,
    TRANSMIT = 2'd1,
    CLOCK_TOGGLE = 2'd2,
    ERROR = 2'd3
} fsm_states;

reg [15:0] data_out;
reg [4:0] bits_left;
reg [1:0] fsm_state;
reg enable, fault, clear;

always @(posedge i_clk or posedge i_rst_b) begin
    if (i_rst_b) begin
        data_out <= 16'h0000;
        bits_left <= 5'h0F;
        fsm_state <= IDLE;
    end else begin
        if (i_enable &&!enable) begin
            enable <= 1'b1;
            fsm_state <= TRANSMIT;
        end else if (!i_enable && enable) begin
            enable <= 1'b0;
            fsm_state <= IDLE;
        end
        
        case (fsm_state)
            IDLE: begin
                if (clear) begin
                    enable <= 1'b0;
                    fsm_state <= IDLE;
                end
            end
            
            TRANSMIT: begin
                data_out <= i_data_in[15:0];
                bits_left <= 5'h0F;
                fsm_state <= CLOCK_TOGGLE;
            end
            
            CLOCK_TOGGLE: begin
                if (bits_left == 5'h00) begin
                    fsm_state <= ERROR;
                end else begin
                    fsm_state <= TRANSMIT;
                    bits_left <= bits_left - 1;
                end
            end
            
            ERROR: begin
                enable <= 1'b0;
                fsm_state <= IDLE;
            end
        endcase
    end
end

assign o_spi_cs_b = ~enable;
assign o_spi_clk = ~|data_out;
assign o_spi_data = data_out[15:8];
assign o_bits_left = bits_left;
assign o_done = (fsm_state == IDLE)? 1'b0 : 1'b1;
assign o_fsm_state = fsm_state;

endmodule