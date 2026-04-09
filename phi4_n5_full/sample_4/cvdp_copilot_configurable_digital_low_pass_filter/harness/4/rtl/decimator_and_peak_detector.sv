module advanced_decimator_with_adaptive_peak_detection #(
  parameter int N           = 8,
  parameter int DATA_WIDTH  = 16,
  parameter int DEC_FACTOR  = 4
)(
  input  logic                   clk,
  input  logic                   reset,
  input  logic                   valid_in,
  input  logic [DATA_WIDTH*N-1:0] data_in,
  output logic                   valid_out,
  output logic [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
  output logic [DATA_WIDTH-1:0]  peak_value
);

  // Ensure that DEC_FACTOR divides N. Uncomment the following static assertion if your tool supports it.
  // static_assert((N % DEC_FACTOR) == 0, "DEC_FACTOR must be a divisor of N");

  // Register to hold the unpacked input samples.
  logic signed [DATA_WIDTH-1:0] samples_reg [0:N-1];
  // Register to hold the valid signal.
  logic valid_reg;

  // Register the input samples and valid signal on the rising edge of clk.
  // When reset is active, clear the registers.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      valid_reg <= 1'b0;
      for (int i = 0; i < N; i++) begin
        samples_reg[i] <= '0;
      end
    end
    else if (valid_in) begin
      valid_reg <= 1'b1;
      // Unpack the packed data_in into individual samples.
      for (int i = 0; i < N; i++) begin
        samples_reg[i] <= data_in[((i+1)*DATA_WIDTH)-1 -: DATA_WIDTH];
      end
    end
  end

  // Combinational logic to generate the decimated output and peak detection.
  always_comb begin
    // Propagate the registered valid signal.
    valid_out = valid_reg;

    // Pack the decimated samples into data_out.
    // For each decimated sample, select samples_reg[i*DEC_FACTOR].
    for (int i = 0; i < N/DEC_FACTOR; i++) begin
      data_out[((i+1)*DATA_WIDTH)-1 -: DATA_WIDTH] = samples_reg[i*DEC_FACTOR];
    end

    // Peak detection: find the maximum value among the decimated samples.
    // Initialize peak_value with the first decimated sample.
    peak_value = samples_reg[0];
    for (int i = 1; i < N/DEC_FACTOR; i++) begin
      if (samples_reg[i*DEC_FACTOR] > peak_value)
        peak_value = samples_reg[i*DEC_FACTOR];
    end
  end

endmodule