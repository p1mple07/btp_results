module fsm_seq_detector(
    input  bit         clk_in,   // 50% duty cycle clock
    input  logic       rst_in,   // asynchronous active-high reset
    input  logic       seq_in,   // serial input bit (0 or 1)
    output logic       seq_detected  // asserted high for one clock cycle when sequence detected
);

  // Define the state encoding using a 3-bit type (S0 to S7)
  typedef enum logic [2:0] {
    S0, // initial state, expecting '1'
    S1, // matched "1"
    S2, // matched "10"
    S3, // matched "101"
    S4, // matched "1011"
    S5, // matched "10110"
    S6, // matched "101100"
    S7  // matched "1011000", expecting final '1'
  } state_t;

  // State registers
  state_t cur_state, next_state;

  // Wire for the combinational output signal
  logic seq_detected_w;

  // Next state and output logic (combinational)
  always_comb begin
    // Default assignments
    next_state = cur_state;
    seq_detected_w = 1'b0;

    case (cur_state)
      S0: begin
        // Expecting a '1' to start the sequence
        if (seq_in == 1'b1)
          next_state = S1;
        else
          next_state = S0;
      end

      S1: begin
        // Sequence so far: "1". Expecting '0'
        if (seq_in == 1'b0)
          next_state = S2;
        else
          // Overlap: if input is '1', restart the sequence (remain in S1)
          next_state = S1;
      end

      S2: begin
        // Sequence so far: "10". Expecting '1'
        if (seq_in == 1'b1)
          next_state = S3;
        else
          // Input does not match; restart from S0 (since new sequence must start with '1')
          next_state = S0;
      end

      S3: begin
        // Sequence so far: "101". Expecting '1'
        if (seq_in == 1'b1)
          next_state = S4;
        else
          next_state = S0;
      end

      S4: begin
        // Sequence so far: "1011". Expecting '0'
        if (seq_in == 1'b0)
          next_state = S5;
        else
          // Overlap: if input is '1', restart sequence from S1
          next_state = S1;
      end

      S5: begin
        // Sequence so far: "10110". Expecting '0'
        if (seq_in == 1'b0)
          next_state = S6;
        else
          // Overlap: if input is '1', restart sequence from S1
          next_state = S1;
      end

      S6: begin
        // Sequence so far: "101100". Expecting '0'
        if (seq_in == 1'b0)
          next_state = S7;
        else
          // Overlap: if input is '1', restart sequence from S1
          next_state = S1;
      end

      S7: begin
        // Sequence so far: "1011000". Expecting final '1'
        if (seq_in == 1'b1) begin
          // Full sequence detected. For overlapping, transition to S1.
          next_state = S1;
          seq_detected_w = 1'b1;
        end else begin
          // Mismatch; restart from S0
          next_state = S0;
        end
      end
    endcase
  end

  // Sequential block: state and output registration
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in) begin
      cur_state   <= S0;
      seq_detected <= 1'b0;
    end else begin
      cur_state   <= next_state;
      seq_detected <= seq_detected_w;
    end
  end

endmodule