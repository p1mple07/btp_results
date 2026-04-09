module digital_dice_roller (
  input wire clk,
  input wire reset_n,
  input wire button,
  output reg [2:0] dice_value
);

// Internal signals
reg [2:0] counter;
reg [2:0] next_counter;
reg idle_state;
reg rolling_state;

always @(posedge clk or posedge reset_n) begin
  if (!reset_n) begin
    idle_state <= 1'b1;
    rolling_state <= 1'b0;
    counter <= 3'b000;
    dice_value <= 3'b000;
  end else begin
    // Next state logic
    if (button &&!idle_state) begin
      idle_state <= 1'b0;
      rolling_state <= 1'b1;
      counter <= 3'b000;
    end else if (!button &&!rolling_state) begin
      idle_state <= 1'b1;
      rolling_state <= 1'b0;
      dice_value <= counter;
    end

    // State transition logic
    case ({idle_state, rolling_state})
      2'b00: begin
        next_counter = counter + 1;
      end
      2'b01: begin
        next_counter = counter;
      end
      2'b10: begin
        next_counter = counter - 1;
      end
      2'b11: begin
        next_counter = counter;
      end
    endcase

    // Register update logic
    if (next_counter > 3'b111) begin
      counter <= 3'b000;
    end else begin
      counter <= next_counter;
    end
  end
end

endmodule