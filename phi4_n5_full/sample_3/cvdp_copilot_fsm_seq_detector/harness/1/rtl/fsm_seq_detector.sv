module fsm_seq_detector (
  input  bit         clk_in,  // 50% duty cycle clock
  input  logic       rst_in,  // asynchronous active-high reset
  input  logic       seq_in,  // serial input bit stream
  output logic       seq_detected  // pulse high for one clk when sequence detected
);

  // Define state encoding using a 3-bit vector
  typedef enum logic [2:0] {
    S0 = 3'b000,  // no match yet
    S1 = 3'b001,  // matched "1"
    S2 = 3'b010,  // matched "10"
    S3 = 3'b011,  // matched "101"
    S4 = 3'b100,  // matched "1011"
    S5 = 3'b101,  // matched "10110"
    S6 = 3'b110,  // matched "101100"
    S7 = 3'b111   // matched "1011000"
  } state_t;

  // State registers and next state wire
  state_t cur_state, next_state;
  logic seq_detected_w;  // combinational detection pulse

  // Next state and output logic (combinational)
  always_comb begin
    // Default assignments
    next_state = cur_state;
    seq_detected_w = 1'b0;

    case (cur_state)
      S0: begin
        if (seq_in)
          next_state = S1;
        else
          next_state = S0;
      end

      S1: begin
        // In S1, if input is 1, remain in S1 (overlap possibility)
        if (seq_in)
          next_state = S1;
        else
          next_state = S2;
      end

      S2: begin
        // Looking for "101" -> next expected bit is 1
        if (seq_in)
          next_state = S3;
        else
          next_state = S0;
      end

      S3: begin
        // Looking for "1011" -> next expected bit is 1
        if (seq_in)
          next_state = S4;
        else
          next_state = S0;
      end

      S4: begin
        // Looking for "10110" -> next expected bit is 0
        if (seq_in == 0)
          next_state = S5;
        else
          // On mismatch, overlap: the last bit "1" can start a new sequence
          next_state = S1;
      end

      S5: begin
        // Looking for "101100" -> next expected bit is 0
        if (seq_in == 0)
          next_state = S6;
        else
          // Mismatch: fallback to state corresponding to matched "1"
          next_state = S1;
      end

      S6: begin
        // Looking for "1011000" -> next expected bit is 0
        if (seq_in == 0)
          next_state = S7;
        else
          // Mismatch: fallback to state S1 (overlap possibility)
          next_state = S1;
      end

      S7: begin
        // In S7, the 8th bit of the sequence is expected.
        // If input is 1, full sequence "10110001" is detected.
        if (seq_in == 1) begin
          seq_detected_w = 1'b1;
          // After detection, follow overlap: the last bit "1" can start a new sequence.
          next_state = S1;
        end else begin
          next_state = S0;
        end
      end

      default: begin
        next_state = S0;
      end
    endcase
  end

  // Sequential state register: update on rising edge of clk_in or asynchronous reset
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
      cur_state <= S0;
    else
      cur_state <= next_state;
  end

  // Register the output signal to avoid glitches.
  // seq_detected is asserted for one clock cycle when a full match occurs.
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in)
      seq_detected <= 1'b0;
    else
      seq_detected <= seq_detected_w;
  end

endmodule