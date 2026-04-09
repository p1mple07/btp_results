module factorial(
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
    IDLE = 2'd0,
    BUSY = 2'd1,
    DONE = 2'd2
  } state_t;

  state_t state, next_state;

  // Internal registers
  reg [4:0]  n;      // latched input number
  reg [4:0]  cnt;    // counter for number of multiplications remaining
  reg [63:0] prod;   // running product for factorial
  reg [63:0] fact_reg; // register to hold final result for output

  // FSM sequential process
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      state       <= IDLE;
      busy        <= 1'b0;
      done        <= 1'b0;
      n           <= 5'd0;
      cnt         <= 5'd0;
      prod        <= 64'd1;
      fact_reg    <= 64'd0;
    end else begin
      case (state)
        IDLE: begin
          busy <= 1'b0;
          done <= 1'b0;
          // Latch new input when start is asserted
          if (start) begin
            n    <= num_in;
            prod <= 64'd1;
            cnt  <= num_in;
            // Special case: if input is 0, factorial is defined as 1 and no cycles are needed.
            if (num_in == 5'd0)
              state <= DONE;
            else
              state <= BUSY;
          end
        end

        BUSY: begin
          busy <= 1'b1;
          // Perform one multiplication per cycle.
          // The multiplier factor is (n - cnt + 1). For example, for n=5:
          //   cnt=5 -> factor = 1, prod = 1*1 = 1
          //   cnt=4 -> factor = 2, prod = 1*2 = 2
          //   cnt=3 -> factor = 3, prod = 2*3 = 6
          //   cnt=2 -> factor = 4, prod = 6*4 = 24
          //   cnt=1 -> factor = 5, prod = 24*5 = 120
          if (cnt > 5'd0) begin
            prod <= prod * (n - cnt + 1);
            cnt  <= cnt - 1;
          end else begin
            state <= DONE;
          end
          done <= 1'b0;
        end

        DONE: begin
          busy <= 1'b0;
          done <= 1'b1;
          fact_reg <= prod; // Drive the final factorial result
          state <= IDLE;    // Return to IDLE for new input
        end

        default: state <= IDLE;
      endcase
    end
  end

  // Output assignments
  assign busy = (state == BUSY);
  assign done = (state == DONE);
  assign fact = fact_reg;

endmodule