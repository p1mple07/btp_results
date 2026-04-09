module advanced_decimator_with_adaptive_peak_detection #(
  parameter int unsigned N = 8, // total number of input samples
  parameter int unsigned DATA_WIDTH = 16, // bit-width of each sample
  parameter int unsigned DEC_FACTOR = 4 // decimation factor
)(
  input clk, // clock signal
  input reset, // asynchronous reset
  input valid_in, // input validation signal indicating valid data
  input [DATA_WIDTH*N-1:0] data_in, // packed input data (N samples of integer signed values)
  output logic valid_out, // output validation signal indicating valid decimated data
  output logic [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out, // packed decimated output data, containing (N / DEC_FACTOR) samples, each of size DATA_WIDTH
  output logic [DATA_WIDTH-1:0] peak_value // peak value among the decimated samples, with a size of DATA_WIDTH
);

  // Register for input data
  logic [DATA_WIDTH*N-1:0] reg_data;

  // Local variables for decimation and peak detection
  logic [DATA_WIDTH-1:0] decimated_samples[N];
  logic [DATA_WIDTH-1:0] peak_value_reg;

  // Logic for input unpacking
  assign decimated_samples = $past(data_in, {N-1{DATA_WIDTH}});

  // Logic for decimation
  generate
    if (DEC_FACTOR == 1) begin
      assign decimated_samples = data_in;
    end else begin
      always @(posedge clk or posedge reset) begin
        if (reset) begin
          decimated_samples <= 'h0;
        end else begin
          decimated_samples <= $past(data_in, {N-1{DATA_WIDTH}});
        end
      end
    end
  endgenerate

  // Logic for peak detection
  always @(*) begin
    if (valid_in) begin
      peak_value_reg = decimated_samples[0];
      for (int i = 1; i < N; i++) begin
        if (decimated_samples[i] > peak_value_reg) begin
          peak_value_reg = decimated_samples[i];
        end
      end
    end
  end

  // Logic for output packing
  assign data_out = decimated_samples[(N/DEC_FACTOR)-1:0];

  // Logic for validation control
  always @(*) begin
    if (reset) begin
      valid_out <= 1'b0;
    end else begin
      valid_out <= valid_in;
    end
  end

  // Assign peak value to output port
  assign peak_value = peak_value_reg;

endmodule