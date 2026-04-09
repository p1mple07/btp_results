module hill_cipher(
  input  logic         clk,
  input  logic         reset,
  input  logic         start,
  input  logic [14:0]  plaintext,  // [14:10]: letter0, [9:5]: letter1, [4:0]: letter2
  input  logic [44:0]  key,        // 3x3 key matrix stored as:
                                   // key[44:40] = K00, key[39:35] = K01, key[34:30] = K02,
                                   // key[29:25] = K10, key[24:20] = K11, key[19:15] = K12,
                                   // key[14:10] = K20, key[9:5]  = K21, key[4:0]  = K22
  output logic [14:0]  ciphertext, // [14:10]: C0, [9:5]: C1, [4:0]: C2
  output logic         done
);

  //-------------------------------------------------------------------------
  // Parameter definitions for FSM states
  //-------------------------------------------------------------------------
  typedef enum logic [2:0] {
    STATE_IDLE  = 3'd0,
    STATE_COMPUTE0 = 3'd1,
    STATE_COMPUTE1 = 3'd2,
    STATE_COMPUTE2 = 3'd3,
    STATE_DONE   = 3'd4
  } state_t;

  state_t state, next_state;

  //-------------------------------------------------------------------------
  // Internal registers for plaintext letters and key matrix elements
  //-------------------------------------------------------------------------
  // Plaintext letters (each 5 bits)
  logic [4:0] p0, p1, p2;
  // Key matrix elements (each 5 bits)
  logic [4:0] k00, k01, k02;
  logic [4:0] k10, k11, k12;
  logic [4:0] k20, k21, k22;

  //-------------------------------------------------------------------------
  // Registers for partial sums (each sum is 12 bits wide)
  //-------------------------------------------------------------------------
  logic [11:0] sum0, sum1, sum2;

  //-------------------------------------------------------------------------
  // Registers for final ciphertext letters (each 5 bits)
  //-------------------------------------------------------------------------
  logic [4:0] c0, c1, c2;

  //-------------------------------------------------------------------------
  // FSM sequential process
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state          <= STATE_IDLE;
      sum0           <= 12'd0;
      sum1           <= 12'd0;
      sum2           <= 12'd0;
      ciphertext     <= 15'd0;
      done           <= 1'b0;
    end
    else begin
      case (state)
        STATE_IDLE: begin
          if (start) begin
            // Latch plaintext and key matrix values
            p0  <= plaintext[14:10];
            p1  <= plaintext[9:5];
            p2  <= plaintext[4:0];
            k00 <= key[44:40];
            k01 <= key[39:35];
            k02 <= key[34:30];
            k10 <= key[29:25];
            k11 <= key[24:20];
            k12 <= key[19:15];
            k20 <= key[14:10];
            k21 <= key[9:5];
            k22 <= key[4:0];
            state <= STATE_COMPUTE0;
          end
        end

        STATE_COMPUTE0: begin
          // Compute column 0 contributions:
          // C0 = k00 * p0, C1 = k10 * p0, C2 = k20 * p0
          sum0 <= k00 * p0;
          sum1 <= k10 * p0;
          sum2 <= k20 * p0;
          state <= STATE_COMPUTE1;
        end

        STATE_COMPUTE1: begin
          // Compute column 1 contributions and add:
          // C0 += k01 * p1, C1 += k11 * p1, C2 += k21 * p1
          sum0 <= sum0 + k01 * p1;
          sum1 <= sum1 + k11 * p1;
          sum2 <= sum2 + k21 * p1;
          state <= STATE_COMPUTE2;
        end

        STATE_COMPUTE2: begin
          // Compute column 2 contributions and add:
          // C0 += k02 * p2, C1 += k12 * p2, C2 += k22 * p2
          sum0 <= sum0 + k02 * p2;
          sum1 <= sum1 + k12 * p2;
          sum2 <= sum2 + k22 * p2;
          // Now compute modulo 26 for each row
          c0 <= mod26(sum0);
          c1 <= mod26(sum1);
          c2 <= mod26(sum2);
          // Combine results into ciphertext (MSB: C0, then C1, then C2)
          ciphertext <= { c0, c1, c2 };
          done       <= 1'b1;
          state      <= STATE_DONE;
        end

        STATE_DONE: begin
          // One cycle pulse for done signal then return to idle
          done <= 1'b0;
          state <= STATE_IDLE;
        end

        default: state <= STATE_IDLE;
      endcase
    end
  end

  //-------------------------------------------------------------------------
  // Function: mod26
  // Computes the remainder when a 12-bit value is divided by 26.
  // This function uses an iterative subtraction method.
  //-------------------------------------------------------------------------
  function automatic [4:0] mod26;
    input [11:0] value;
    integer i;
    [11:0] temp;
    temp = value;
    // Unroll a fixed number of iterations (112 iterations is sufficient for values up to 2883)
    for (i = 0; i < 112; i = i + 1) begin
      if (temp >= 12'd26)
        temp = temp - 12'd26;
      else
        break;
    end
    mod26 = temp[4:0];
  endfunction

endmodule