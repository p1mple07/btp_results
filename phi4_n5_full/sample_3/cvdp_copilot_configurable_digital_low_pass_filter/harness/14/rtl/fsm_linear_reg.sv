module fsm_linear_reg #(
    parameter DATA_WIDTH = 16
)(
    input  logic                  clk,
    input  logic                  reset,
    input  logic                  start,
    input  logic signed [DATA_WIDTH-1:0] x_in,
    input  logic signed [DATA_WIDTH-1:0] w_in,
    input  logic signed [DATA_WIDTH-1:0] b_in,
    output logic signed [2*DATA_WIDTH-1:0] result1,
    output logic signed [DATA_WIDTH:0] result2,
    output logic                  done
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE  = 2'b00,
    COMPUTE = 2'b01,
    DONE   = 2'b10
  } state_t;

  // Internal registers
  state_t state, next_state;
  // A 1-bit counter to introduce the required latency in the COMPUTE state
  logic compute_cnt;  
  // Intermediate result registers (to capture computed values)
  logic signed [2*DATA_WIDTH-1:0] inter_result1;
  logic signed [DATA_WIDTH:0]     inter_result2;

  // Sequential logic: state machine and output registers
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      compute_cnt   <= 1'b0;
      inter_result1 <= '0;
      inter_result2 <= '0;
      result1       <= '0;
      result2       <= '0;
      done          <= 1'b0;
    end
    else begin
      case (state)
        IDLE: begin
          if (start) begin
            // Transition to COMPUTE; initialize counter
            state        <= COMPUTE;
            compute_cnt  <= 1'b0;
          end
          else begin
            state <= IDLE;
          end
        end

        COMPUTE: begin
          if (compute_cnt == 1'b0) begin
            // First cycle in COMPUTE: compute intermediate values.
            // result1 is computed as (w_in * x_in) shifted right by 1 (arithmetic shift)
            // result2 is computed as b_in + (x_in shifted right by 2)
            inter_result1 <= ( $signed(w_in) * $signed(x_in) ) >>> 1;
            inter_result2 <= $signed(b_in) + ( $signed(x_in) >>> 2 );
            // Increment counter to delay output update by one additional cycle
            compute_cnt <= 1'b1;
          end
          else begin
            // Second cycle in COMPUTE: update outputs and transition to DONE.
            result1 <= inter_result1;
            result2 <= inter_result2;
            state   <= DONE;
          end
        end

        DONE: begin
          // Assert done for one clock cycle then return to IDLE.
          done <= 1'b1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule