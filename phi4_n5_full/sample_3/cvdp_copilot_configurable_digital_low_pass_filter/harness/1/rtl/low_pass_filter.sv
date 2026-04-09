module low_pass_filter #(
  parameter DATA_WIDTH = 16,
  parameter COEFF_WIDTH = 16,
  parameter NUM_TAPS   = 8
)(
  input  logic                    clk,
  input  logic                    reset,
  input  logic [DATA_WIDTH*NUM_TAPS-1:0] data_in,
  input  logic                    valid_in,
  input  logic [COEFF_WIDTH*NUM_TAPS-1:0] coeffs,
  output logic [NBW_MULT + $clog2(NUM_TAPS)-1:0] data_out,
  output logic                    valid_out
);

  // Derived parameter: width of intermediate multiplication results.
  localparam int NBW_MULT = DATA_WIDTH + COEFF_WIDTH;
  // Derived parameter: width required for final summation result.
  localparam int OUT_WIDTH = NBW_MULT + $clog2(NUM_TAPS);

  //-------------------------------------------------------------------------
  // Internal Registers: 
  // These registers store the incoming data and coefficients when valid_in
  // is asserted. When valid_in is low, the previous values are retained.
  //-------------------------------------------------------------------------
  reg [DATA_WIDTH-1:0] data_reg [0:NUM_TAPS-1];
  reg [COEFF_WIDTH-1:0] coeff_reg [0:NUM_TAPS-1];

  //-------------------------------------------------------------------------
  // Registered Output Data:
  // The computed convolution result is registered here to introduce one
  // clock cycle of latency.
  //-------------------------------------------------------------------------
  reg [OUT_WIDTH-1:0] data_out_reg;

  //-------------------------------------------------------------------------
  // Combinational Logic: Multiplication and Accumulation
  //
  // The registered input data and coefficients are used to compute the 
  // convolution. Note that the coefficients are applied in reverse order:
  // the first data sample is multiplied by the last coefficient, the second
  // by the second-to-last, and so on.
  //-------------------------------------------------------------------------
  logic [NBW_MULT-1:0] product [0:NUM_TAPS-1];
  logic [OUT_WIDTH-1:0] sum;

  always_comb begin
    sum = '0;
    for (int i = 0; i < NUM_TAPS; i++) begin
      // Reverse the coefficient order: data_reg[i] * coeff_reg[NUM_TAPS-1-i]
      product[i] = data_reg[i] * coeff_reg[NUM_TAPS-1-i];
      sum = sum + product[i];
    end
  end

  //-------------------------------------------------------------------------
  // Sequential Logic: Input Registering and Output Registration
  //
  // On every clock cycle:
  // - If reset is high, clear all internal registers and outputs.
  // - If valid_in is high, update the data_reg and coeff_reg with new values.
  // - Register the valid_in signal to valid_out (one cycle latency).
  // - Register the computed sum into data_out_reg.
  //-------------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Clear all registered data and coefficients.
      for (int i = 0; i < NUM_TAPS; i++) begin
        data_reg[i] <= '0;
        coeff_reg[i] <= '0;
      end
      valid_out   <= 1'b0;
      data_out_reg<= '0;
    end
    else begin
      if (valid_in) begin
        // Update registers with new input data and coefficients.
        for (int i = 0; i < NUM_TAPS; i++) begin
          data_reg[i] <= data_in[(i+1)*DATA_WIDTH-1 -: DATA_WIDTH];
          coeff_reg[i] <= coeffs[(i+1)*COEFF_WIDTH-1 -: COEFF_WIDTH];
        end
      end
      // Register valid_in with one cycle latency.
      valid_out   <= valid_in;
      // Register the convolution result.
      data_out_reg<= sum;
    end
  end

  // Drive the output port with the registered data.
  assign data_out = data_out_reg;

endmodule