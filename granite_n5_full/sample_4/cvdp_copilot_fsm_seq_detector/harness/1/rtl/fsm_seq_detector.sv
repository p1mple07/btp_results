module fsm_seq_detector #(
  parameter logic [2:0] ResetState = 3'b000
) (
  // Clock & Reset
  input  logic          clk_in,
  input  logic          rst_in,

  // Input Stream
  input  logic          seq_in,

  // Output Signal
  output logic          seq_detected
);

  typedef enum logic [2:0] {
    S0, S1, S2, S3, S4, S5, S6, S7
  } state_t;

  state_t cur_state, next_state;
  logic    seq_detected_w;

  // Sequential Logic
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      cur_state <= ResetState;
    end else begin
      cur_state <= next_state;
    end
  end

  // Next State Logic
  always_comb begin
    case (cur_state)
      S0: begin
        if      (seq_in == 1'b1) next_state = S1;
        else                     next_state = S0;
      end
      S1: begin
        if      (seq_in == 1'b1) next_state = S2;
        else                     next_state = S1;
      end
      S2: begin
        if      (seq_in == 1'b1) next_state = S3;
        else                     next_state = S2;
      end
      S3: begin
        if      (seq_in == 1'b1) next_state = S4;
        else                     next_state = S3;
      end
      S4: begin
        if      (seq_in == 1'b1) next_state = S5;
        else                     next_state = S4;
      end
      S5: begin
        if      (seq_in == 1'b1) next_state = S6;
        else                     next_state = S5;
      end
      S6: begin
        if      (seq_in == 1'b1) next_state = S7;
        else                     next_state = S6;
      end
      S7: begin
        if      (seq_in == 1'b1) next_state = S0;
        else                     next_state = S7;
      end
      default: next_state = S0;
    endcase
  end

  // Output Logic
  assign seq_detected_w = |cur_state[2:0];
  always_ff @(posedge clk_in) begin
    seq_detected <= seq_detected_w;
  end

endmodule