module spi_fsm (
    input  wire         i_clk,       // System clock
    input  wire         i_rst_b,     // Active-low async reset
    input  wire [15:0]  i_data_in,   // 16-bit data to transmit
    input  wire         i_enable,    // Enable block
    input  wire         i_fault,     // Fault indicator
    input  wire         i_clear,     // Forces FSM to clear/idle
    
    output reg          o_spi_cs_b,  // SPI chip select (active-low)
    output reg          o_spi_clk,   // SPI clock
    output reg          o_spi_data,  // Serialized SPI data out
    output reg [4:0]    o_bits_left, // Bits remaining to transmit (default: 16)
    output reg          o_done,      // One-cycle pulse when done or error
    output reg [1:0]    o_fsm_state  // FSM state: 00=Idle, 01=Transmit, 10=Clock Toggle, 11=Error
);

  // State encoding
  localparam IDLE   = 2'b00;
  localparam TX     = 2'b01;
  localparam CLKTOG = 2'b10;
  localparam ERROR  = 2'b11;

  // Internal registers
  reg [1:0] state;
  reg [15:0] shift_reg;  // Shift register holding data to be transmitted
  reg [4:0] bits_left;   // Number of bits remaining
  reg toggle_clk;        // Internal clock toggle signal

  // Asynchronous reset and control signals have highest priority.
  // i_fault: Transition to ERROR state.
  // i_clear: Immediately go to IDLE.
  always @(posedge i_clk or negedge i_rst_b) begin
    if (!i_rst_b) begin
      state         <= IDLE;
      o_spi_cs_b    <= 1'b1;
      o_spi_clk     <= 1'b0;
      o_spi_data    <= 1'b0;
      bits_left     <= 5'd16;
      o_done        <= 1'b0;
      o_fsm_state   <= 2'b00;
      shift_reg     <= 16'd0;
      toggle_clk    <= 1'b0;
    end
    else begin
      // Check for fault or clear conditions first.
      if (i_fault) begin
        state         <= ERROR;
        o_spi_cs_b    <= 1'b1;
        o_spi_clk     <= 1'b0;
        o_spi_data    <= 1'b0;
        bits_left     <= 5'd16;
        o_done        <= 1'b0;
        o_fsm_state   <= 2'b11;
        shift_reg     <= 16'd0;
        toggle_clk    <= 1'b0;
      end
      else if (i_clear) begin
        state         <= IDLE;
        o_spi_cs_b    <= 1'b1;
        o_spi_clk     <= 1'b0;
        o_spi_data    <= 1'b0;
        bits_left     <= 5'd16;
        o_done        <= 1'b0;
        o_fsm_state   <= 2'b00;
        shift_reg     <= 16'd0;
        toggle_clk    <= 1'b0;
      end
      else begin
        case (state)
          IDLE: begin
            // In Idle: Wait for i_enable to start transmission.
            if (i_enable) begin
              state         <= TX;
              shift_reg     <= i_data_in;  // Load data into shift register
              bits_left     <= 5'd16;       // Reset bit counter to 16
              o_spi_cs_b    <= 1'b0;        // Assert chip select (active low)
              o_spi_clk     <= 1'b0;        // Start with clock low
              o_spi_data    <= shift_reg[15]; // Output MSB
              o_done        <= 1'b0;
              o_fsm_state   <= 2'b01;       // TX state
              toggle_clk    <= 1'b0;
            end
            else begin
              state         <= IDLE;
              o_spi_cs_b    <= 1'b1;        // Deassert CS when idle
              o_spi_clk     <= 1'b0;
              o_spi_data    <= 1'b0;
              bits_left     <= bits_left;   // Remain unchanged
              o_done        <= 1'b0;
              o_fsm_state   <= 2'b00;
              toggle_clk    <= 1'b0;
            end
          end

          TX: begin
            // In Transmit: Simply transition to Clock Toggle.
            state         <= CLKTOG;
            o_spi_cs_b    <= 1'b0;
            o_spi_clk     <= 1'b0;
            o_spi_data    <= shift_reg[15];
            o_done        <= 1'b0;
            o_fsm_state   <= 2'b01;
            toggle_clk    <= 1'b0;
          end

          CLKTOG: begin
            // Toggle the SPI clock.
            toggle_clk    <= ~toggle_clk;
            o_spi_clk     <= toggle_clk;
            // Shift the data left by one bit.
            shift_reg     <= shift_reg << 1;
            // Decrement the bit counter.
            bits_left     <= bits_left - 1;
            // Check if all bits have been transmitted.
            if ((bits_left - 1) == 5'd0) begin
              state         <= IDLE;
              o_done        <= 1'b1;  // Assert done pulse for one cycle
              o_fsm_state   <= 2'b00;
              o_spi_cs_b    <= 1'b1;  // Deassert chip select
              o_spi_clk     <= 1'b0;
              o_spi_data    <= 1'b0;
            end
            else begin
              state         <= TX;
              o_done        <= 1'b0;
              o_fsm_state   <= 2'b01;
              o_spi_cs_b    <= 1'b0;
              o_spi_clk     <= 1'b0;
              o_spi_data    <= shift_reg[15];
            end
          end

          ERROR: begin
            // In Error state: Hold outputs at safe defaults.
            state         <= ERROR;
            o_spi_cs_b    <= 1'b1;
            o_spi_clk     <= 1'b0;
            o_spi_data    <= 1'b0;
            bits_left     <= 5'd16;
            o_done        <= 1'b0;
            o_fsm_state   <= 2'b11;
            shift_reg     <= 16'd0;
            toggle_clk    <= 1'b0;
          end

          default: begin
            state         <= IDLE;
            o_spi_cs_b    <= 1'b1;
            o_spi_clk     <= 1'b0;
            o_spi_data    <= 1'b0;
            bits_left     <= 5'd16;
            o_done        <= 1'b0;
            o_fsm_state   <= 2'b00;
            shift_reg     <= 16'd0;
            toggle_clk    <= 1'b0;
          end
        endcase
      end
    end
  end

endmodule