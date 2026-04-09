module cvdp_prbs_gen #(
    // Configuration parameters
    parameter int unsigned POLY_LENGTH = 31,
    parameter int unsigned POLY_TAP     = 3,
    parameter int unsigned WIDTH        = 16
)(
    // Module ports
    input  wire clk,
    input  wire rst,
    input  wire [WIDTH-1:0] data_in,
    output      [WIDTH-1:0] data_out
);

  // Define local variables and constants
  localparam int unsigned MAX_TAP = POLY_TAP;
  localparam int unsigned NUM_BITS = $clog2(POLY_LENGTH+1);
  typedef enum logic {GEN, CHECK} CHECK_MODE_E;

  // Define LFSR state and feedback taps
  logic [POLY_LENGTH:0] prbs_reg;
  logic [MAX_TAP-1:0] feedback_tap;

  // Generate PRBS pattern
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      // Reset internal states and outputs
      prbs_reg <= '1;
      data_out <= '1;
    end else begin
      // Calculate feedback taps
      feedback_tap <= ((~poly_mask) & poly_mask_shifted) | (poly_mask << 1);

      // Update PRBS register
      prbs_reg <= {prbs_reg[POLY_LENGTH], prbs_reg[NUM_BITS-1:0]} ^ feedback_tap;

      // Output data_out
      data_out <= prbs_reg[WIDTH-1:0];
    end
  end

  // Perform error checking in checker mode
  assign data_out = (check_mode == CHECK)? (data_in ^ prbs_reg[WIDTH-1:0]) : '0;

endmodule