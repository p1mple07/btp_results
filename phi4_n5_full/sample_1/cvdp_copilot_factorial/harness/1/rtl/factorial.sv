module factorial(
    input  logic         clk,
    input  logic         arst_n,
    input  logic [4:0]   num_in,
    input  logic         start,
    output logic         busy,
    output logic         done,
    output logic [63:0]  fact
);

  // FSM state encoding: IDLE, BUSY, DONE
  typedef enum logic [1:0] {
    IDLE = 2'b00,
    BUSY = 2'b01,
    DONE = 2'b10
  } state_t;

  state_t state, next_state;

  // Internal registers to hold the captured input, product, and iteration counter
  logic [4:0] n_reg;       // Captured input number
  logic [63:0] product;    // Running product for factorial computation
  logic [4:0] counter;     // Iteration counter

  // Output assignments: busy is high in BUSY state, done is high in DONE state.
  // fact is valid only in DONE state; otherwise it is 0.
  always_comb begin
    busy = (state == BUSY);
    done = (state == DONE);
    if (state == DONE)
      fact = product;
    else
      fact = 64'd0;
  end

  // FSM sequential process with asynchronous active low reset
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      state         <= IDLE;
      n_reg         <= 5'd0;
      product       <= 64'd1;
      counter       <= 5'd0;
      // busy and done are driven by the state combinational logic
    end else begin
      case (state)
        IDLE: begin
          // Accept new input only if start is asserted and design is not busy.
          if (start && !busy) begin
            n_reg     <= num_in;   // Capture the input number
            product   <= 64'd1;    // Initialize product to 1
            counter   <= 5'd0;     // Start counter at 0
            state     <= BUSY;     // Transition to BUSY state
          end else begin
            state <= IDLE;
          end
        end

        BUSY: begin
          // Perform one multiplication per cycle.
          // Multiply product by (counter + 1) and increment counter.
          if (counter < n_reg) begin
            product   <= product * (counter + 1);
            counter   <= counter + 1;
            state     <= BUSY;
          end else begin
            state <= DONE;  // All iterations done; move to DONE state.
          end
        end

        DONE: begin
          // In DONE state, fact is output (see combinational block).
          // Then clear internal registers and return to IDLE.
          state     <= IDLE;
          product   <= 64'd1;
          counter   <= 5'd0;
          n_reg     <= 5'd0;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule