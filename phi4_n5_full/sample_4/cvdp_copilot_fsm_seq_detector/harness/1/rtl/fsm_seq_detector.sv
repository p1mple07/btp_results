module fsm_seq_detector (
    input  bit         clk_in,    // 50% duty cycle clock
    input  logic       rst_in,    // asynchronous active-high reset
    input  logic       seq_in,    // serial input bit (0 or 1)
    output logic       seq_detected // asserted high for one clk when sequence detected
);

  // Define the 3-bit state encoding for 8 states: S0 to S7
  typedef enum logic [2:0] {
    S0 = 3'b000,
    S1 = 3'b001,
    S2 = 3'b010,
    S3 = 3'b011,
    S4 = 3'b100,
    S5 = 3'b101,
    S6 = 3'b110,
    S7 = 3'b111
  } state_t;

  state_t state, next_state;
  logic seq_detected_w;  // combinational signal for seq_detected

  // Next state and output logic (combinational)
  always_comb begin
    // Default assignments
    next_state = state;
    seq_detected_w = 1'b0;
    case (state)
      S0: begin
        if (seq_in)
          next_state = S1;
        else
          next_state = S0;
      end
      S1: begin
        if (!seq_in)
          next_state = S2;
        else
          next_state = S1;  // if input is 1, remain in S1 (pattern prefix "1")
      end
      S2: begin
        if (seq_in)
          next_state = S3;
        else
          next_state = S0;
      end
      S3: begin
        if (seq_in)
          next_state = S4;
        else
          next_state = S1;
      end
      S4: begin
        if (!seq_in)
          next_state = S5;
        else
          next_state = S1;
      end
      S5: begin
        if (!seq_in)
          next_state = S6;
        else
          next_state = S2;
      end
      S6: begin
        if (!seq_in)
          next_state = S7;
        else
          next_state = S2;
      end
      S7: begin
        if (seq_in) begin
          next_state = S0;
          seq_detected_w = 1'b1;  // sequence detected: output high this cycle
        end
        else begin
          next_state = S0;
        end
      end
      default: begin
        next_state = S0;
      end
    endcase
  end

  // Sequential always block: state register and registered output
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      state      <= S0;
      seq_detected <= 1'b0;
    end
    else begin
      state      <= next_state;
      seq_detected <= seq_detected_w;
    end
  end

endmodule