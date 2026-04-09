module Attenuator (
    input        clk,
    input        reset,
    input  [4:0] data,
    output reg   ATTN_CLK,
    output reg   ATTN_DATA,
    output reg   ATTN_LE
);

  // Internal Signals
  reg        clk_div2;
  reg  [1:0] current_state, next_state;
  reg  [4:0] shift_reg;
  reg  [2:0] bit_count;
  reg  [4:0] old_data;
  reg        latch_counter; // Used to generate a one-cycle pulse in LATCH state

  // Parameters for FSM States
  localparam IDLE  = 2'b00,
             LOAD  = 2'b01,
             SHIFT = 2'b10,
             LATCH = 2'b11;

  // Clock Divider: Generate a slower clock (divide system clock by 2)
  always @(posedge clk or posedge reset) begin
    if (reset)
      clk_div2 <= 1'b0;
    else
      clk_div2 <= ~clk_div2;
  end

  // FSM for serial data shifting and latching
  always @(posedge clk_div2 or posedge reset) begin
    if (reset) begin
      current_state   <= IDLE;
      ATTN_CLK        <= 1'b0;
      ATTN_DATA       <= 1'b0;
      ATTN_LE         <= 1'b0;
      shift_reg       <= 5'b00000;
      bit_count       <= 3'd0;
      old_data        <= 5'b00000;
      latch_counter   <= 1'b0;
    end else begin
      current_state <= next_state;
      case (current_state)
        IDLE: begin
          // Transition to LOAD if new data is detected
          if (data != old_data)
            next_state = LOAD;
          else
            next_state = IDLE;
          ATTN_CLK  <= 1'b0;
          ATTN_DATA <= 1'b0;
          ATTN_LE   <= 1'b0;
        end
        LOAD: begin
          // Capture new data and reset the bit counter
          shift_reg <= data;
          bit_count <= 3'd0;
          old_data  <= data;
          next_state = SHIFT;
          ATTN_CLK  <= 1'b0;
          ATTN_DATA <= 1'b0;
          ATTN_LE   <= 1'b0;
        end
        SHIFT: begin
          // Output the LSB of the shift register
          ATTN_DATA <= shift_reg[0];
          // Drive the attenuator clock using the divided clock signal
          ATTN_CLK  <= clk_div2;
          // Shift the register right by one bit
          shift_reg <= shift_reg >> 1;
          // Increment the bit counter
          bit_count <= bit_count + 1;
          // After shifting 5 bits, transition to LATCH state
          if (bit_count == 4)
            next_state = LATCH;
          else
            next_state = SHIFT;
        end
        LATCH: begin
          // Generate a one-cycle pulse on ATTN_LE
          if (latch_counter == 1'b0) begin
            ATTN_LE    <= 1'b1;
            latch_counter <= 1'b1;
            next_state = LATCH; // Remain in LATCH for one more cycle
          end else begin
            ATTN_LE    <= 1'b0;
            latch_counter <= 1'b0;
            next_state = IDLE;
          end
          ATTN_DATA <= 1'b0;
          ATTN_CLK  <= 1'b0;
        end
      endcase
    end
  end

endmodule