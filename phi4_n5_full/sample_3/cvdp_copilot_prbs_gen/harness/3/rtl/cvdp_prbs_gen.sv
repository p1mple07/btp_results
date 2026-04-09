module cvdp_prbs_gen #(
  parameter int CHECK_MODE = 0,    // 0 = Generator Mode, 1 = Checker Mode
  parameter int POLY_LENGTH = 31,  // Length of the LFSR (number of stages)
  parameter int POLY_TAP   = 3,    // Tap position (assumed 1-indexed; tap at POLY_LENGTH is the MSB)
  parameter int WIDTH      = 16    // Width of data_in and data_out buses
) (
  input  logic         clk,
  input  logic         rst,
  input  logic [WIDTH-1:0] data_in,
  output logic [WIDTH-1:0] data_out
);

  //-------------------------------------------------------------------------
  // Parameter Checks (compile-time assertions)
  //-------------------------------------------------------------------------
  // Ensure that the polynomial length is at least as large as the tap position,
  // that the tap is positive, and that WIDTH is positive.
  static_assert(POLY_LENGTH >= POLY_TAP, "Error: POLY_LENGTH must be >= POLY_TAP");
  static_assert(POLY_TAP > 0, "Error: POLY_TAP must be a positive integer");
  static_assert(WIDTH > 0, "Error: WIDTH must be a positive integer");

  //-------------------------------------------------------------------------
  // Internal Registers and Wires
  //-------------------------------------------------------------------------
  // LFSR register: using POLY_LENGTH bits. Index [POLY_LENGTH-1] is the MSB.
  logic [POLY_LENGTH-1:0] lfsr_reg;

  // Expected PRBS pattern slice: most significant WIDTH bits of the LFSR.
  // In Generator Mode, this is the output pattern.
  // In Checker Mode, this is used for comparison.
  logic [WIDTH-1:0] expected_prbs;

  // Feedback bit computed as the XOR of the MSB (position POLY_LENGTH)
  // and the tap bit (position POLY_TAP). (Assumes 1-indexed positions.)
  logic feedback_bit;

  //-------------------------------------------------------------------------
  // Sequential Logic: LFSR Update and Output Generation
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      // On reset, initialize the LFSR to all ones and force data_out to all ones.
      lfsr_reg <= {POLY_LENGTH{1'b1}};
      data_out  <= {WIDTH{1'b1}};
    end else begin
      if (CHECK_MODE == 0) begin
        //-------------------------------------------------------------------------
        // Generator Mode (CHECK_MODE = 0)
        //-------------------------------------------------------------------------
        // Compute the feedback bit as the XOR of:
        //   - The MSB (bit at position POLY_LENGTH, i.e. index POLY_LENGTH-1)
        //   - The tap bit (bit at position POLY_TAP, i.e. index POLY_TAP-1)
        feedback_bit = lfsr_reg[POLY_LENGTH-1] ^ lfsr_reg[POLY_TAP-1];

        // Update the LFSR: shift right by one and insert the feedback bit at the MSB.
        // This produces the next state of the PRBS.
        lfsr_reg <= {feedback_bit, lfsr_reg[POLY_LENGTH-1:1]};

        // In Generator Mode, output the most significant WIDTH bits of the LFSR.
        data_out <= lfsr_reg[POLY_LENGTH-1:POLY_LENGTH-WIDTH];
      end else begin
        //-------------------------------------------------------------------------
        // Checker Mode (CHECK_MODE = 1)
        //-------------------------------------------------------------------------
        // Even in Checker Mode, we update the LFSR in the same way to generate
        // the expected PRBS pattern.
        feedback_bit = lfsr_reg[POLY_LENGTH-1] ^ lfsr_reg[POLY_TAP-1];
        lfsr_reg <= {feedback_bit, lfsr_reg[POLY_LENGTH-1:1]};

        // Extract the expected PRBS pattern from the LFSR.
        expected_prbs = lfsr_reg[POLY_LENGTH-1:POLY_LENGTH-WIDTH];

        // Compare the incoming data with the expected PRBS pattern.
        // The XOR of data_in and expected_prbs yields a nonzero value for any bit
        // discrepancy. Thus, data_out will be nonzero if there is an error.
        data_out <= data_in ^ expected_prbs;
      end
    end
  end

endmodule