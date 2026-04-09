module fsm_linear_reg #(
  parameter DATA_WIDTH = 16
)(
  input  logic                   clk,
  input  logic                   reset,
  input  logic                   start,
  input  logic signed [DATA_WIDTH-1:0] x_in,
  input  logic signed [DATA_WIDTH-1:0] w_in,
  input  logic signed [DATA_WIDTH-1:0] b_in,
  output logic [2*DATA_WIDTH-1:0] result1,
  output logic [DATA_WIDTH:0]    result2,
  output logic                   done
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    COMPUTE = 2'b01,
    DONE   = 2'b10
  } state_t;

  state_t state, next_state;
  // A one-bit counter to create a two-cycle pipeline in the COMPUTE state.
  logic compute_cnt;

  // Pipeline registers to hold the computed combinational results.
  logic [2*DATA_WIDTH-1:0] result_reg1;
  logic [DATA_WIDTH:0]     result_reg2;

  // Combinational result calculations
  // result1_comb = w_in * x_in >>> 1
  // result2_comb = b_in + (x_in >>> 2)
  always_comb begin
    result_reg1  = (w_in * x_in) >>> 1;
    result_reg2  = {1'b0, b_in} + (x_in >>> 2);
  end

  // Next state logic
  always_comb begin
    next_state = state; // default
    case (state)
      IDLE: begin
        if (start)
          next_state = COMPUTE;
        else
          next_state = IDLE;
      end
      COMPUTE: begin
        // If we have completed the two-cycle pipeline in COMPUTE, move to DONE.
        if (compute_cnt)
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

  // Sequential logic: state register, pipeline registers, and output registers.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      compute_cnt   <= 1'b0;
      result_reg1   <= {2*DATA_WIDTH{1'b0}};
      result_reg2   <= {DATA_WIDTH+1{1'b0}};
      result1       <= {2*DATA_WIDTH{1'b0}};
      result2       <= {DATA_WIDTH+1{1'b0}};
      done          <= 1'b0;
    end
    else begin
      state <= next_state;
      case (state)
        IDLE: begin
          compute_cnt   <= 1'b0;
          result1       <= {2*DATA_WIDTH{1'b0}};
          result2       <= {DATA_WIDTH+1{1'b0}};
          done          <= 1'b0;
        end
        COMPUTE: begin
          if (compute_cnt == 1'b0) begin
            // First cycle of COMPUTE: capture combinational results.
            result_reg1   <= (w_in * x_in) >>> 1;
            result_reg2   <= {1'b0, b_in} + (x_in >>> 2);
            compute_cnt   <= 1'b1;
          end
          else begin
            // Second cycle of COMPUTE: update outputs with pipelined results.
            result1       <= result_reg1;
            result2       <= result_reg2;
            // The next state will transition to DONE (as set by next_state logic)
            compute_cnt   <= 1'b0;
          end
        end
        DONE: begin
          // Assert done for one clock cycle.
          done          <= 1'b1;
          // Clear outputs (or hold them as needed; here we reset to zero).
          result1       <= {2*DATA_WIDTH{1'b0}};
          result2       <= {DATA_WIDTH+1{1'b0}};
        end
        default: begin
          state         <= IDLE;
          compute_cnt   <= 1'b0;
          result1       <= {2*DATA_WIDTH{1'b0}};
          result2       <= {DATA_WIDTH+1{1'b0}};
          done          <= 1'b0;
        end
      endcase
    end
  end

endmodule