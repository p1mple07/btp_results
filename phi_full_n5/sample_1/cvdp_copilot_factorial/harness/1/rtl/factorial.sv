module factorial #(parameter WIDTH = 5)
  (
    input clk,
    input arst_n,
    input [WIDTH-1:0] num_in,
    input start,
    output reg busy,
    output reg [63:0] fact,
    output reg done
  );

  typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
  state_t current_state, next_state;

  // State transition table
  localparam [state_t * state_t] state_table =  {
    {IDLE, BUSY},
    {BUSY, DONE}
  };

  // FSM implementation
  always @(posedge clk or posedge arst_n) begin
    if (arst_n) begin
      current_state <= IDLE;
      fact <= 1;
      busy <= 1;
      done <= 0;
    end else if (start && current_state == IDLE) begin
      current_state <= BUSY;
      busy <= 1;
      done <= 0;
    end else if (current_state == BUSY) begin
      for (int i = WIDTH; i > 0; i--) begin
        fact <= fact * i;
        if (i == 1) begin
          done <= 1;
          busy <= 0;
        end
      end
    end

    next_state = state_table[current_state][current_state];
    current_state <= next_state;
  end

endmodule
