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
  reg  [1:0] current_state;
  reg  [4:0] shift_reg;
  reg  [2:0] bit_count;
  reg  [4:0] old_data;

  // Parameters for FSM States
  localparam IDLE  = 2'b00,
             LOAD  = 2'b01,
             SHIFT = 2'b10,
             LATCH = 2'b11;

  // Reset Condition
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      clk_div2      <= 1'b0;
      current_state <= IDLE;
      ATTN_CLK      <= 1'b0;
      ATTN_DATA     <= 1'b0;
      ATTN_LE       <= 1'b0;
      shift_reg     <= 5'b00000;
      bit_count     <= 3'd0;
      old_data      <= 5'b00000;
    end else begin
      // Toggle the clock divider on every clock edge
      clk_div2 <= ~clk_div2;
      
      // Update FSM and outputs only when clk_div2 is high
      if (clk_div2) begin
        case (current_state)
          IDLE: begin
            // Transition to LOAD if new data is detected
            if (data !== old_data) begin
              old_data      <= data;
              current_state <= LOAD;
            end else begin
              current_state <= IDLE;
            end
            // In IDLE, all outputs remain inactive
            ATTN_CLK   <= 1'b0;
            ATTN_DATA  <= 1'b0;
            ATTN_LE    <= 1'b0;
          end

          LOAD: begin
            // Capture the new control word into the shift register
            shift_reg   <= data;
            bit_count   <= 3'd0;
            current_state <= SHIFT;
            // Outputs remain inactive during LOAD
            ATTN_CLK   <= 1'b0;
            ATTN_DATA  <= 1'b0;
            ATTN_LE    <= 1'b0;
          end

          SHIFT: begin
            // Output the most significant bit
            ATTN_DATA  <= shift_reg[4];
            // Shift the register left by one
            shift_reg  <= shift_reg << 1;
            // Increment the bit counter
            bit_count  <= bit_count + 1;
            // After shifting all 5 bits, transition to LATCH
            if (bit_count == 4) begin
              current_state <= LATCH;
            end else begin
              current_state <= SHIFT;
            end
            // Drive ATTN_CLK with the clock divider (or simply high)
            ATTN_CLK   <= clk_div2;
            ATTN_LE    <= 1'b0;
          end

          LATCH: begin
            // Pulse ATTN_LE high for one cycle to latch the data
            ATTN_LE    <= 1'b1;
            current_state <= IDLE;
            // Ensure other outputs are inactive
            ATTN_CLK   <= 1'b0;
            ATTN_DATA  <= 1'b0;
          end

          default: begin
            current_state <= IDLE;
          end
        endcase
      end
    end
  end

endmodule