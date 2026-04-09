module fsm_seq_detector (
  input  logic clk_in,
  input  logic rst_in,
  input  logic seq_in,
  output logic seq_detected
);

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

  state_t cur_state, next_state;
  logic seq_detected_w;

  // Sequential always block triggered on rising edge of clk_in or rst_in
  always_ff @(posedge clk_in or posedge rst_in) begin
    if (rst_in == 1'b1) begin
      cur_state <= S0;
      seq_detected_w <= 1'b0;
    end else begin
      cur_state <= next_state;
      seq_detected_w <= seq_detected;
    end
  end

  // Combinational always block to compute next_state
  always_comb begin
    case (cur_state)
      S0: begin
        if (seq_in == 1'b1) begin
          next_state = S1;
        end else begin
          next_state = S0;
        end
      end

      S1: begin
        if (seq_in == 1'b0) begin
          next_state = S2;
        end else begin
          next_state = S1;
        end
      end

      S2: begin
        if (seq_in == 1'b1) begin
          next_state = S3;
        end else begin
          next_state = S2;
        end
      end

      S3: begin
        if (seq_in == 1'b0) begin
          next_state = S4;
        end else begin
          next_state = S3;
        end
      end

      S4: begin
        if (seq_in == 1'b1) begin
          next_state = S5;
        end else begin
          next_state = S4;
        end
      end

      S5: begin
        if (seq_in == 1'b0) begin
          next_state = S6;
        end else begin
          next_state = S5;
        end
      end

      S6: begin
        if (seq_in == 1'b1) begin
          next_state = S7;
        end else begin
          next_state = S6;
        end
      end

      S7: begin
        if (seq_in == 1'b0) begin
          next_state = S0;
        end else begin
          next_state = S7;
        end
      end

      default: next_state = S0;
    endcase
  end

  // Register seq_detected in a sequential always block to synchronize it with clk_in
  always_ff @(posedge clk_in) begin
    seq_detected <= seq_detected_w;
  end

endmodule