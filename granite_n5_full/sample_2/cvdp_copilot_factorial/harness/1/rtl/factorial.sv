module factorial (
  input wire clk,
  input wire arst_n,
  input wire [4:0] num_in,
  input wire start,
  output reg busy,
  output reg [63:0] fact,
  output reg done
);

  localparam NUM_BITS = 5;
  localparam FACTORIAL_WIDTH = 64;
  
  // State machine FSM
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    BUSY = 2'b01,
    DONE = 2'b10
  } fsm_state_t;
  
  fsm_state_t state, next_state;
  
  // Internal signals
  reg [NUM_BITS:0] counter;
  reg [FACTORIAL_WIDTH-1:0] temp_fact;
  reg [FACTORIAL_WIDTH:0] accu_fact;
  
  always @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      // Reset
      state <= IDLE;
      counter <= 0;
      temp_fact <= 0;
      accu_fact <= 0;
    end else begin
      // Next state logic
      case (state)
        IDLE: begin
          if (start) begin
            next_state <= BUSY;
            accu_fact <= 0;
            counter <= num_in;
          end else begin
            next_state <= IDLE;
          end
        end
        BUSY: begin
          if (counter == 0) begin
            next_state <= DONE;
          end else begin
            next_state <= BUSY;
          end
        end
        DONE: begin
          next_state <= IDLE;
        end
      endcase
    end
  end
  
  always @(posedge clk or posedge arst_n) begin
    if (!arst_n) begin
      // Reset outputs
      fact <= 0;
      done <= 0;
    end else begin
      // Output assignments based on current state
      unique case (state)
        IDLE: begin
          // Output assignments when in IDLE state
        end
        BUSY: begin
          // Output assignments when in BUSY state
        end
        DONE: begin
          // Output assignments when in DONE state
        end
      endcase
    end
  end
  
endmodule