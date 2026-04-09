module low_pass_filter #(
  parameter integer DATA_WIDTH = 16,       // Bit-width of the input data
  parameter integer COEFF_WIDTH = 16,      // Bit-width of the filter coefficients
  parameter integer NUM_TAPS = 8           // Number of filter taps
) (
  input  logic                        clk,
  input  logic                        reset,
  input  logic [DATA_WIDTH*NUM_TAPS-1:0] data_in,  // Packed input data: NUM_TAPS samples
  input  logic                        valid_in,
  input  logic [COEFF_WIDTH*NUM_TAPS-1:0] coeffs, // Packed coefficients: NUM_TAPS coefficients
  output logic [NBW_MULT + $clog2(NUM_TAPS)-1:0] data_out, // Filtered output data
  output logic                        valid_out
);

  // Derived parameters
  localparam integer NBW_MULT    = DATA_WIDTH + COEFF_WIDTH;  // Intermediate multiplication width
  localparam integer TAPS_LOG2   = $clog2(NUM_TAPS);           // Bits needed for tap count in summation
  localparam integer OUTPUT_WIDTH = NBW_MULT + TAPS_LOG2;      // Final output width

  //-------------------------------------------------------------------------
  // Internal registers for input data and coefficients
  //-------------------------------------------------------------------------
  // Registered data samples (each NUM_TAPS sample stored as a signed value)
  logic signed [DATA_WIDTH-1:0] data_reg [0:NUM_TAPS-1];
  // Registered coefficients (each NUM_TAPS coefficient stored as a signed value)
  logic signed [COEFF_WIDTH-1:0] coeff_reg [0:NUM_TAPS-1];

  //-------------------------------------------------------------------------
  // Combinational logic: Element-wise multiplication and summation
  //-------------------------------------------------------------------------
  // Each product is computed with width NBW_MULT bits.
  logic signed [NBW_MULT-1:0] product [0:NUM_TAPS-1];
  // Summation result computed as a combinational sum of all products.
  // The output width is OUTPUT_WIDTH to account for the sum of NUM_TAPS terms.
  logic signed [OUTPUT_WIDTH-1:0] sum_comb;

  //-------------------------------------------------------------------------
  // Registers for the computed sum and valid signal (1-cycle latency)
  //-------------------------------------------------------------------------
  logic signed [OUTPUT_WIDTH-1:0] sum_reg;
  logic valid_reg;

  //-------------------------------------------------------------------------
  // Registering input data and coefficients when valid_in is high.
  // If reset is asserted, all internal registers are cleared to zero.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      for (int i = 0; i < NUM_TAPS; i = i + 1) begin
        data_reg[i] <= '0;
        coeff_reg[i] <= '0;
      end
      valid_reg <= 1'b0;
    end else if (valid_in) begin
      for (int i = 0; i < NUM_TAPS; i = i + 1) begin
        // Unpack each tap from the packed bus using the "-:" operator.
        data_reg[i] <= data_in[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
        coeff_reg[i] <= coeffs[(i+1)*COEFF_WIDTH-1 -: COEFF_WIDTH];
      end
      valid_reg <= valid_in; // Propagate validity with one-cycle latency
    end
  end

  //-------------------------------------------------------------------------
  // Combinational block for performing element-wise multiplication and summation.
  // Note: The coefficients are applied in reverse order relative to the data.
  //-------------------------------------------------------------------------
  always_comb begin
    sum_comb = '0;
    for (int i = 0; i < NUM_TAPS; i = i + 1) begin
      // Multiply data_reg[i] with the coefficient in reverse order:
      // i.e., first data sample with last coefficient, etc.
      product[i] = data_reg[i] * coeff_reg[NUM_TAPS-1-i];
      sum_comb = sum_comb + product[i];
    end
  end

  //-------------------------------------------------------------------------
  // Register the computed sum to introduce a one-cycle latency.
  // The valid_out signal is also registered here.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      sum_reg <= '0;
      valid_reg <= 1'b0;
    end else begin
      sum_reg <= sum_comb;
      valid_reg <= valid_in;
    end
  end

  //-------------------------------------------------------------------------
  // Output assignments
  //-------------------------------------------------------------------------
  assign data_out = sum_reg;
  assign valid_out = valid_reg;

endmodule