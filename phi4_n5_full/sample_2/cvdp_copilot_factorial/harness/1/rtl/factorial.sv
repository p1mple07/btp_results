module factorial (
  input  logic         clk,
  input  logic         arst_n,
  input  logic [4:0]   num_in,
  input  logic         start,
  output logic         busy,
  output logic [63:0]  fact,
  output logic         done
);

  // Define FSM states
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    BUSY = 2'b01,
    DONE = 2'b10
  } state_t;

  state_t state, next_state;

  // Internal registers
  logic [4:0] counter;       // holds the current multiplier value
  logic [63:0] fact_reg;     // holds the computed factorial

  // Next state logic (combinational)
  always_comb begin
    next_state = state;
    case (state)
      IDLE: begin
        if (start)
          next_state = BUSY;
      end
      BUSY: begin
        if (counter == 5'd0)
          next_state = DONE;
        else
          next_state = BUSY;
      end
      DONE: begin
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  // Sequential logic: state update, register updates, and output driving
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      state         <= IDLE;
      counter       <= 5'd0;
      fact_reg      <= 64'd1;
      busy          <= 1'b0;
      done          <= 1'b0;
    end
    else begin
      state <= next_state;
      case (state)
        IDLE: begin
          // Capture input and initialize computation
          if (start) begin
            counter <= num_in;
            fact_reg <= 64'd1;
          end
          busy <= 1'b0;
          done <= 1'b0;
        end
        BUSY: begin
          if (counter != 5'd0) begin
            // Multiply fact_reg by the current counter value
            fact_reg <= fact_reg * counter;
            counter <= counter - 5'd1;
          end
          busy <= 1'b1;
          done <= 1'b0;
        end
        DONE: begin
          // Hold the result for one cycle
          busy <= 1'b0;
          done <= 1'b1;
        end
        default: begin
          busy <= 1'b0;
          done <= 1'b0;
        end
      endcase
    end
  end

  // Drive the output
  assign fact = fact_reg;

endmodule