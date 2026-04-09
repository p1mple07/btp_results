module fsm_linear_reg #(
  parameter DATA_WIDTH = 16
)(
  input  logic clk,
  input  logic reset,
  input  logic start,
  input  logic signed [DATA_WIDTH-1:0] x_in,
  input  logic signed [DATA_WIDTH-1:0] w_in,
  input  logic signed [DATA_WIDTH-1:0] b_in,
  output logic signed [2*DATA_WIDTH-1:0] result1,
  output logic signed [DATA_WIDTH:0] result2,
  output logic done
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    COMPUTE = 2'b01,
    DONE   = 2'b10
  } state_t;

  state_t state, next_state;
  // A 1-bit counter used in the COMPUTE state to implement the 2-cycle delay
  logic compute_counter; // 0: first cycle, 1: second cycle

  // Intermediate computed values (to meet the latency requirement)
  logic signed [2*DATA_WIDTH-1:0] computed_result1;
  logic signed [DATA_WIDTH:0] computed_result2;

  // Next state logic
  always_comb begin
    next_state = state;
    case (state)
      IDLE: begin
        if (start)
          next_state = COMPUTE;
        else
          next_state = IDLE;
      end
      COMPUTE: begin
        // Remain in COMPUTE until the counter has advanced
        if (compute_counter == 1)
          next_state = DONE;
        else
          next_state = COMPUTE;
      end
      DONE: begin
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Sequential logic: state, compute_counter, and outputs
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state            <= IDLE;
      compute_counter  <= 0;
      computed_result1 <= 0;
      computed_result2 <= 0;
      result1          <= 0;
      result2          <= 0;
      done             <= 0;
    end
    else begin
      case (state)
        IDLE: begin
          if (start) begin
            state            <= COMPUTE;
            compute_counter  <= 0;  // Start counter in COMPUTE state
          end
          // Otherwise remain in IDLE
        end
        COMPUTE: begin
          if (compute_counter == 0) begin
            // First cycle of COMPUTE: compute intermediate results
            computed_result1 <= (w_in * x_in) >>> 1;
            computed_result2 <= b_in + (x_in >>> 2);
            compute_counter  <= 1;
          end
          else begin  // Second cycle of COMPUTE: update outputs and transition
            result1 <= computed_result1;
            result2 <= computed_result2;
            state   <= DONE;
          end
        end
        DONE: begin
          // Assert done for one clock cycle then return to IDLE
          done <= 1;
          state <= IDLE;
        end
        default: state <= IDLE;
      endcase
    end
  end

endmodule