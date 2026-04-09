module cvdp_prbs_gen #(
  parameter int CHECK_MODE = 0,       // 0: Generator, 1: Checker
  parameter int POLY_LENGTH = 31,      // Length of the LFSR (number of stages)
  parameter int POLY_TAP   = 3,        // Tap position (0-indexed; must be < POLY_LENGTH)
  parameter int WIDTH      = 16        // Width of data_in and data_out buses
)(
  input  logic         clk,
  input  logic         rst,           // Active-high synchronous reset
  input  logic [WIDTH-1:0] data_in,   // In generator mode, assumed 0; in checker mode, expected PRBS pattern
  output logic [WIDTH-1:0] data_out   // In generator mode: generated PRBS pattern; in checker mode: error vector
);

  // Parameter checks (compile-time)
  initial begin
    if (POLY_LENGTH < POLY_TAP)
      $error("Parameter error: POLY_LENGTH (%0d) must be >= POLY_TAP (%0d)", POLY_LENGTH, POLY_TAP);
    if (POLY_TAP < 1)
      $error("Parameter error: POLY_TAP (%0d) must be a positive integer", POLY_TAP);
    if (WIDTH < 1)
      $error("Parameter error: WIDTH (%0d) must be a positive integer", WIDTH);
  end

  // Internal PRBS register (LFSR) of size POLY_LENGTH bits.
  // Bit [POLY_LENGTH-1] is the MSB.
  logic [POLY_LENGTH-1:0] prbs_reg;

  // Error vector used in checker mode.
  logic [WIDTH-1:0] error;

  // LFSR feedback calculation:
  // The feedback bit is computed as the XOR of the bit at position POLY_TAP and the MSB (bit POLY_LENGTH-1).
  // (Assumes bit positions are 0-indexed.)
  always_ff @(posedge clk) begin
    if (rst) begin
      // On reset, initialize PRBS register to all ones and set data_out to all ones.
      prbs_reg  <= { {POLY_LENGTH{1'b1}} };
      data_out  <= { {WIDTH{1'b1}} };
    end else begin
      if (CHECK_MODE == 0) begin
        // Generator Mode
        // Compute the feedback bit.
        logic fb;
        fb = prbs_reg[POLY_TAP] ^ prbs_reg[POLY_LENGTH-1];
        // Update the PRBS register: shift right and insert the feedback bit at the MSB.
        prbs_reg <= {fb, prbs_reg[POLY_LENGTH-1:1]};
        // Output the lower WIDTH bits of the PRBS register as the generated pattern.
        data_out <= prbs_reg[WIDTH-1:0];
      end else begin
        // Checker Mode
        // Generate the expected PRBS pattern using the same LFSR logic.
        logic fb;
        fb = prbs_reg[POLY_TAP] ^ prbs_reg[POLY_LENGTH-1];
        logic [POLY_LENGTH-1:0] prbs_next;
        prbs_next = {fb, prbs_reg[POLY_LENGTH-1:1]};
        // Compare each bit of the expected pattern (lower WIDTH bits) with data_in.
        // If there is a mismatch, the corresponding bit in 'error' is set.
        integer i;
        for (i = 0; i < WIDTH; i++) begin
          error[i] = (prbs_next[i] !== data_in[i]);
        end
        // In checker mode, data_out carries the error vector.
        // A non-zero value indicates at least one bit discrepancy.
        data_out <= error;
        // Update the PRBS register with the expected pattern for the next cycle.
        prbs_reg <= prbs_next;
      end
    end
  end

endmodule