module low_pass_filter #(
  parameter DATA_WIDTH = 16,
  parameter COEFF_WIDTH = 16,
  parameter NUM_TAPS   = 8
) (
  input  logic                         clk,
  input  logic                         reset,
  input  logic [DATA_WIDTH*NUM_TAPS-1:0] data_in,
  input  logic                         valid_in,
  input  logic [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,
  output logic [NBW_MULT+$clog2(NUM_TAPS)-1:0] data_out,
  output logic                         valid_out
);

  // Define intermediate and output widths
  localparam integer NBW_MULT = DATA_WIDTH + COEFF_WIDTH;
  localparam integer OUT_WIDTH = NBW_MULT + $clog2(NUM_TAPS);

  // Internal registers to store the registered input data and coefficients.
  // These registers hold NUM_TAPS samples each.
  logic signed [DATA_WIDTH-1:0] data_reg [0:NUM_TAPS-1];
  logic signed [COEFF_WIDTH-1:0] coeff_reg [0:NUM_TAPS-1];

  // Register to hold the valid signal (one-cycle delay).
  logic valid_reg;

  // Register to hold the computed convolution result.
  logic signed [OUT_WIDTH-1:0] result_reg;

  // Intermediate combinational result of the convolution.
  logic signed [OUT_WIDTH-1:0] result_comb;

  // Combinational Logic:
  // Convert the registered 1D streams into an effective 2D array and perform
  // element-wise multiplication with reversed coefficient order, then sum the products.
  always_comb begin
    result_comb = '0;
    for (int i = 0; i < NUM_TAPS; i++) begin
      // Multiply the i-th data tap by the corresponding coefficient from the reversed order.
      logic signed [NBW_MULT-1:0] product;
      product = data_reg[i] * coeff_reg[NUM_TAPS-1 - i];
      // Extend the product to the output width before accumulation.
      result_comb = result_comb + {{(OUT_WIDTH - NBW_MULT){1'b0}}, product};
    end
  end

  // Sequential Logic:
  // On each clock cycle, update the registered data and coefficients if valid_in is high.
  // Compute the convolution result from the stored values and register the output.
  always_ff @(posedge clk) begin
    if (reset) begin
      // Clear all internal registers on reset.
      for (int i = 0; i < NUM_TAPS; i++) begin
        data_reg[i] <= '0;
        coeff_reg[i] <= '0;
      end
      valid_reg   <= 1'b0;
      result_reg  <= '0;
    end
    else begin
      if (valid_in) begin
        // Unpack the packed input data and coefficients into the internal arrays.
        for (int i = 0; i < NUM_TAPS; i++) begin
          data_reg[i] <= data_in[i*DATA_WIDTH +: DATA_WIDTH];
          coeff_reg[i] <= coeffs[i*COEFF_WIDTH +: COEFF_WIDTH];
        end
        valid_reg <= valid_in;
      end
      // Always update the result register with the computed convolution.
      result_reg <= result_comb;
    end
  end

  // Output assignments:
  // data_out is the registered convolution result.
  // valid_out is the one-cycle registered valid signal.
  assign data_out = result_reg;
  assign valid_out = valid_reg;

endmodule