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

  enum logic [1:0] {
    IDLE,
    TRANSMIT,
    CLOCK_TOGGLE,
    ERROR
  } fsm_state;

  always @(posedge i_clk or posedge i_rst_b) begin
    if (i_rst_b == 1'b1) begin
      fsm_state <= IDLE;
      o_spi_cs_b <= 1'b1;
      o_spi_clk <= 1'b0;
      o_spi_data <= 1'b0;
      o_bits_left <= 5'b10;
      o_done <= 1'b0;
      o_fsm_state <= IDLE;
    end else if (i_enable == 1'b1) begin
      case (fsm_state)
        IDLE: begin
          fsm_state <= TRANSMIT;
          o_spi_cs_b <= 1'b0;
          o_spi_data <= i_data_in[15];
          o_bits_left <= 5'b11;
        end
        TRANSMIT: begin
          if (o_bits_left == 5'b0) begin
            o_done <= 1'b1;
            fsm_state <= IDLE;
          end else begin
            o_spi_data <= i_data_in[15 - o_bits_left +: 1];
            o_bits_left <= o_bits_left - 1;
          end
        end
        CLOCK_TOGGLE: begin
          o_spi_clk <= ~o_spi_clk;
          o_bits_left <= o_bits_left - 1;
          if (o_bits_left == 5'b0) begin
            o_done <= 1'b1;
            fsm_state <= IDLE;
          end
        end
        ERROR: begin
          o_spi_cs_b <= 1'b1;
          o_spi_clk <= 1'b0;
          o_spi_data <= 1'b0;
          o_bits_left <= 5'b10;
          o_done <= 1'b0;
          o_fsm_state <= IDLE;
        end
      endcase
    end
  end

  assign o_fsm_state = fsm_state;
  
endmodule