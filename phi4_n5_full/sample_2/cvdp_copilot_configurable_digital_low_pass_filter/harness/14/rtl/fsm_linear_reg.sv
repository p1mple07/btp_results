module fsm_linear_reg #(
  parameter DATA_WIDTH = 16
)(
  input  logic                     clk,
  input  logic                     reset,
  input  logic                     start,
  input  logic signed [DATA_WIDTH-1:0] x_in,
  input  logic signed [DATA_WIDTH-1:0] w_in,
  input  logic signed [DATA_WIDTH-1:0] b_in,
  output logic signed [2*DATA_WIDTH-1:0] result1,
  output logic signed [DATA_WIDTH:0]    result2,
  output logic                         done
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    COMPUTE = 2'b01,
    DONE   = 2'b10
  } state_t;

  // Registers for state, pipeline counter, computed results, and done flag
  state_t state, next_state;
  reg [1:0] comp_counter; // Counter to implement fixed latency in COMPUTE state
  reg signed [2*DATA_WIDTH-1:0] result1_reg;
  reg signed [DATA_WIDTH:0]    result2_reg;
  reg                         done_reg;

  // Synchronous process: state transitions and output updates
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state            <= IDLE;
      comp_counter     <= 0;
      result1_reg      <= { {2*DATA_WIDTH{1'b0}} };
      result2_reg      <= { {DATA_WIDTH+1{1'b0}} };
      done_reg         <= 1'b0;
    end
    else begin
      // Update state based on next_state logic
      state <= next_state;
      
      // State-specific behavior
      case (state)
        IDLE: begin
          // In IDLE: wait for start signal.
          // When start is asserted, prepare to enter COMPUTE.
          if (start) begin
            comp_counter <= 0; // Initialize counter for computation phase
          end
          // Outputs are held at zero.
          result1_reg <= { {2*DATA_WIDTH{1'b0}} };
          result2_reg <= { {DATA_WIDTH+1{1'b0}} };
          done_reg    <= 1'b0;
        end

        COMPUTE: begin
          // In COMPUTE: implement a 2-cycle delay before updating results.
          if (comp_counter < 2) begin
            comp_counter <= comp_counter + 1;
          end
          else begin
            // On the 3rd cycle (i.e. comp_counter==2), compute results using:
            // result1 = (w_in * x_in) >>> 1
            // result2 = b_in + (x_in >>> 2)
            result1_reg <= (w_in * x_in) >>> 1;
            result2_reg <= b_in + (x_in >>> 2);
            // Transition to DONE state in the next cycle.
            // Reset counter for potential future computations.
            comp_counter <= 0;
          end
          // done flag remains deasserted during COMPUTE.
          done_reg <= 1'b0;
        end

        DONE: begin
          // In DONE: assert done for one clock cycle.
          done_reg <= 1'b1;
          // No changes to computed results.
        end
      endcase
    end
  end

  // Next state logic (combinational)
  always_comb begin
    // Default: remain in current state
    next_state = state;
    case (state)
      IDLE: begin
        if (start)
          next_state = COMPUTE;
        else
          next_state = IDLE;
      end

      COMPUTE: begin
        // Remain in COMPUTE until the 2-cycle delay has elapsed.
        if (comp_counter < 2)
          next_state = COMPUTE;
        else
          next_state = DONE;
      end

      DONE: begin
        // After asserting done for one cycle, return to IDLE.
        next_state = IDLE;
      end
    endcase
  end

  // Output assignments
  assign result1 = result1_reg;
  assign result2 = result2_reg;
  assign done    = done_reg;

endmodule