module fsm_seq_detector (
  input logic clk_in,
  input logic rst_in,
  input logic seq_in,
  output logic seq_detected
);

  typedef enum logic [2:0] {
    S0 = 3'd0,
    S1 = 3'd1,
    S2 = 3'd2,
    S3 = 3'd3,
    S4 = 3'd4,
    S5 = 3'd5,
    S6 = 3'd6,
    S7 = 3'd7
  } state_t;

  // State register
  reg state_q;

  // Next state logic
  always_comb begin
    case(state_q)
      S0: begin
        if (seq_in == 1'b1)
          next_state = S1;
        else
          next_state = S0;
      end
      S1: begin
        if (seq_in == 1'b1)
          next_state = S2;
        else
          next_state = S0;
      end
      S2: begin
        if (seq_in == 1'b1)
          next_state = S3;
        else
          next_state = S0;
      end
      S3: begin
        if (seq_in == 1'b1)
          next_state = S4;
        else
          next_state = S0;
      end
      S4: begin
        if (seq_in == 1'b1)
          next_state = S5;
        else
          next_state = S0;
      end
      S5: begin
        if (seq_in == 1'b1)
          next_state = S6;
        else
          next_state = S0;
      end
      S6: begin
        if (seq_in == 1'b1)
          next_state = S7;
        else
          next_state = S0;
      end
      S7: begin
        if (seq_in == 1'b1)
          next_state = S0;
        else
          next_state = S0;
      end
      default: next_state = S0;
    endcase
  end

  // Output logic
  assign seq_detected_w = seq_in & (state_q == S7);
  always @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
      seq_detected <= 1'b0;
    else
      seq_detected <= seq_detected_w;
  end

  // State register update
  always @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
      state_q <= S0;
    else
      state_q <= next_state;
  end

endmodule