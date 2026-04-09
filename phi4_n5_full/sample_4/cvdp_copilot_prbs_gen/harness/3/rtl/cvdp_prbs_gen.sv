module implements a configurable PRBS generator/checker.
// In generator mode (CHECK_MODE==0), it updates an internal LFSR (of width POLY_LENGTH)
// using the feedback computed as the XOR of the bit at position POLY_TAP and the MSB (bit POLY_LENGTH-1).
// The generated PRBS pattern is output on the lower WIDTH bits of data_out.
//
// In checker mode (CHECK_MODE==1), the module performs WIDTH iterative LFSR updates
// starting from the current state of the PRBS register. For each iteration i (0 <= i < WIDTH):
//   - It computes the expected feedback bit using the current state.
//   - It compares the expected bit with the corresponding bit of data_in.
//   - It updates the internal register with the feedback.
// The error for each bit is the XOR of the expected bit and the corresponding data_in bit.
// The resulting error vector is assigned to data_out (a nonzero value indicates a mismatch).
//
// On reset (rst asserted), the PRBS register is initialized to all ones and data_out is set to all ones.
//
module cvdp_prbs_gen #
(
  parameter int CHECK_MODE = 0,       // 0: Generator mode; 1: Checker mode
  parameter int POLY_LENGTH = 31,      // Length of the LFSR (number of stages)
  parameter int POLY_TAP    = 3,       // Tap position (must be less than POLY_LENGTH)
  parameter int WIDTH        = 16      // Width of data_in and data_out buses
)
(
  input  logic         clk,
  input  logic         rst,
  input  logic [WIDTH-1:0] data_in,  // In generator mode, expected to be 0
  output logic [WIDTH-1:0] data_out  // In generator mode: generated PRBS pattern; in checker mode: error bits
);

  // Internal PRBS register (LFSR) of width POLY_LENGTH.
  logic [POLY_LENGTH-1:0] prbs_reg;

  always_ff @(posedge clk) begin
    if (rst) begin
      // On reset, initialize the PRBS register to all ones.
      prbs_reg <= '1;
      data_out <= '1;
    end
    else begin
      if (CHECK_MODE == 0) begin
        // ------------------------------
        // Generator Mode
        // ------------------------------
        //
        // Compute the feedback bit as the XOR of the tap bit and the MSB.
        // Note: MSB is at index POLY_LENGTH-1 (assuming bit 0 is LSB).
        bit fb = prbs_reg[POLY_TAP] ^ prbs_reg[POLY_LENGTH-1];
        
        // Update the PRBS register by shifting right and inserting fb at MSB.
        prbs_reg <= { fb, prbs_reg[POLY_LENGTH-1:1] };
        
        // Output the lower WIDTH bits of the PRBS register.
        data_out <= prbs_reg[WIDTH-1:0];
        
      end else begin
        // ------------------------------
        // Checker Mode
        // ------------------------------
        //
        // In checker mode, we perform WIDTH iterative updates of the LFSR.
        // For each iteration i (0 <= i < WIDTH):
        //   - Compute the expected feedback bit from the current state.
        //   - Compare it with data_in[i] (XOR yields 1 if there is a mismatch).
        //   - Update the internal register.
        // Finally, assign the collected error bits to data_out.
        //
        // Note: This design updates the LFSR WIDTH times per clock cycle.
        // It is assumed that POLY_LENGTH >= WIDTH.
        
        logic [POLY_LENGTH-1:0] temp_reg;
        logic [WIDTH-1:0]       error;
        integer i;
        
        // Start with the current state of the PRBS register.
        temp_reg = prbs_reg;
        
        // Iterate over each bit position of the data bus.
        for (i = 0; i < WIDTH; i++) begin
          // Compute feedback from the current state.
          bit fb = temp_reg[POLY_TAP] ^ temp_reg[POLY_LENGTH-1];
          // Compare the expected feedback bit with the corresponding bit of data_in.
          error[i] = data_in[i] ^ fb;
          // Update the temporary register for the next iteration.
          temp_reg = { fb, temp_reg[POLY_LENGTH-1:1] };
        end
        
        // Update the main PRBS register with the final state.
        prbs_reg <= temp_reg;
        // Output the error bits.
        data_out <= error;
      end
    end
  end

endmodule