module Attenuator (
    input        clk,
    input        reset,
    input  [4:0] data,
    output reg   ATTN_CLK,
    output reg   ATTN_DATA,
    output reg   ATTN_LE
);

  // Internal Signals
  reg         clk_div2;
  reg  [1:0]  current_state, next_state;
  reg  [4:0]  shift_reg;
  reg  [2:0]  bit_count;
  reg  [4:0]  old_data;

  // Parameters for FSM States
  localparam  IDLE  = 2'b00,
              LOAD  = 2'b01,
              SHIFT = 2'b10,
              LATCH = 2'b11;

  //--------------------------------------------------------------------------
  // Clock Divider: Generate a slower clock (clk_div2) for communication.
  // This always block toggles clk_div2 on every posedge of clk.
  //--------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset)
      clk_div2 <= 1'b0;
    else
      clk_div2 <= !clk_div2;
  end

  //--------------------------------------------------------------------------
  // FSM and Output Logic: Driven by the divided clock (clk_div2).
  // The FSM transitions through IDLE, LOAD, SHIFT, and LATCH states.
  //--------------------------------------------------------------------------
  always @(posedge clk_div2 or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
      ATTN_CLK      <= 1'b0;
      ATTN_DATA     <= 1'b0;
      ATTN_LE       <= 1'b0;
      shift_reg     <= 5'b00000;
      bit_count     <= 3'd0;
      old_data      <= 5'b00000;
    end
    else begin
      case (current_state)
        IDLE: begin
          // Wait for new data: if data has changed, move to LOAD.
          if (data !== old_data)
            current_state <= LOAD;
          else
            current_state <= IDLE;
        end

        LOAD: begin
          // Capture the new 5-bit control word.
          shift_reg  <= data;
          bit_count  <= 3'd0;
          current_state <= SHIFT;
        end

        SHIFT: begin
          // Output the most-significant bit (MSB) of the shift register.
          ATTN_DATA <= shift_reg[4];
          // Shift right to bring the next bit into position.
          shift_reg <= shift_reg >> 1;
          bit_count <= bit_count + 1;
          // After shifting 5 bits (bit_count==4 after 5 cycles), go to LATCH.
          if (bit_count == 4)
            current_state <= LATCH;
          else
            current_state <= SHIFT;
        end

        LATCH: begin
          // Pulse the latch enable signal for one cycle.
          ATTN_LE <= 1'b1;
          // Return to IDLE after latching.
          current_state <= IDLE;
        end

        default: current_state <= IDLE;
      endcase
    end
  end

  //--------------------------------------------------------------------------
  // Drive the attenuator chip clock (ATTN_CLK) using the divided clock.
  // This provides the 50% duty cycle needed for synchronization.
  //--------------------------------------------------------------------------
  always @(*) begin
    ATTN_CLK = clk_div2;
  end

endmodule