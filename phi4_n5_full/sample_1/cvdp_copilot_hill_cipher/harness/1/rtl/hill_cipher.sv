module hill_cipher (
    input  logic         clk,
    input  logic         reset,
    input  logic         start,
    input  logic [14:0]  plaintext,  // [14:10] = first letter, [9:5] = second, [4:0] = third
    input  logic [44:0]  key,        // key matrix: [44:40]=K00, [39:35]=K01, [34:30]=K02,
                                  //           [29:25]=K10, [24:20]=K11, [19:15]=K12,
                                  //           [14:10]=K20, [9:5] =K21, [4:0] =K22
    output logic [14:0]  ciphertext, // [14:10] = C0, [9:5] = C1, [4:0] = C2
    output logic         done        // High when encryption is complete
);

  // Define FSM states
  typedef enum logic [2:0] {
    IDLE  = 3'b000,
    CALC0 = 3'b001,
    CALC1 = 3'b010,
    CALC2 = 3'b011,
    DONE  = 3'b100
  } state_t;

  state_t state, next_state;

  // Registers to hold the plaintext letters and key matrix elements
  logic [4:0] p0, p1, p2;
  logic [4:0] k00, k01, k02;
  logic [4:0] k10, k11, k12;
  logic [4:0] k20, k21, k22;

  // Intermediate sum registers (10 bits wide to hold products and additions)
  logic [9:0] sum0, sum1, sum2;

  // Sequential logic: state transitions and data processing
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state      <= IDLE;
      ciphertext <= 15'd0;
      done       <= 1'b0;
      p0         <= 5'd0; p1 <= 5'd0; p2 <= 5'd0;
      k00        <= 5'd0; k01 <= 5'd0; k02 <= 5'd0;
      k10        <= 5'd0; k11 <= 5'd0; k12 <= 5'd0;
      k20        <= 5'd0; k21 <= 5'd0; k22 <= 5'd0;
    end else begin
      case (state)
        IDLE: begin
          if (start) begin
            // Load plaintext letters and key matrix elements
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
            state <= CALC0;
          end
        end

        CALC0: begin
          // Compute first row: C0 = (K00*P0 + K01*P1 + K02*P2) mod 26
          sum0 = k00 * p0 + k01 * p1 + k02 * p2;
          ciphertext[14:10] <= sum0 % 26;
          state <= CALC1;
        end

        CALC1: begin
          // Compute second row: C1 = (K10*P0 + K11*P1 + K12*P2) mod 26
          sum1 = k10 * p0 + k11 * p1 + k12 * p2;
          ciphertext[9:5] <= sum1 % 26;
          state <= CALC2;
        end

        CALC2: begin
          // Compute third row: C2 = (K20*P0 + K21*P1 + K22*P2) mod 26
          sum2 = k20 * p0 + k21 * p1 + k22 * p2;
          ciphertext[4:0] <= sum2 % 26;
          state <= DONE;
        end

        DONE: begin
          // Encryption complete; assert done for one cycle then return to IDLE
          done <= 1'b1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule