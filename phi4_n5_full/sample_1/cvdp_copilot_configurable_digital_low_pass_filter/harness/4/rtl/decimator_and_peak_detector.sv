module advanced_decimator_with_adaptive_peak_detection #(
  parameter N = 8,
  parameter DATA_WIDTH = 16,
  parameter DEC_FACTOR = 4
)(
  input  logic clk,
  input  logic reset,
  input  logic valid_in,
  input  logic [DATA_WIDTH*N-1:0] data_in,
  output logic valid_out,
  output logic [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
  output logic [DATA_WIDTH-1:0] peak_value
);

  //-------------------------------------------------------------------------
  // Input Data Registering
  //-------------------------------------------------------------------------
  // Register the input data and valid signal on the rising edge of clk.
  // When reset is high, clear the registers.
  logic [DATA_WIDTH*N-1:0] data_reg;
  logic valid_reg;

  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      data_reg  <= '0;
      valid_reg <= 1'b0;
    end else begin
      data_reg  <= data_in;
      valid_reg <= valid_in;
    end
  end

  //-------------------------------------------------------------------------
  // Combinational Logic: Decimation and Peak Detection
  //-------------------------------------------------------------------------
  // The following combinational block unpacks the registered data,
  // selects decimated samples (every DEC_FACTOR-th sample), packs them
  // back into a bus, and computes the peak (maximum) value among them.

  // Packed bus for decimated data output.
  logic [DATA_WIDTH*(N/DEC_FACTOR)-1:0] decimated_data;
  // Variable to hold the detected peak value.
  logic signed [DATA_WIDTH-1:0] peak;

  // Local loop indices.
  int i, j;

  // Temporary array to hold individual unpacked samples.
  logic signed [DATA_WIDTH-1:0] samples [0:N-1];
  // Array to hold the decimated samples.
  logic signed [DATA_WIDTH-1:0] decimated [(N/DEC_FACTOR)-1:0];

  always_comb begin
    //-------------------------------------------------------------------------
    // Input Unpacking
    //-------------------------------------------------------------------------
    // Unpack the registered packed data bus into individual samples.
    for (i = 0; i < N; i = i + 1) begin
      samples[i] = data_reg[((i+1)*DATA_WIDTH)-1 -: DATA_WIDTH];
    end

    //-------------------------------------------------------------------------
    // Decimation
    //-------------------------------------------------------------------------
    // Select one sample for every DEC_FACTOR samples.
    // The decimated dataset contains N/DEC_FACTOR samples.
    for (j = 0; j < (N/DEC_FACTOR); j = j + 1) begin
      decimated[j] = samples[j * DEC_FACTOR];
    end

    //-------------------------------------------------------------------------
    // Output Packing
    //-------------------------------------------------------------------------
    // Pack the decimated samples back into a bus.
    // The concatenation order ensures the first decimated sample is the MSB.
    decimated_data = '0;
    for (j = 0; j < (N/DEC_FACTOR); j = j + 1) begin
      decimated_data = {decimated_data, decimated[j]};
    end

    //-------------------------------------------------------------------------
    // Peak Detection
    //-------------------------------------------------------------------------
    // Initialize the peak with the first decimated sample.
    peak = decimated[0];
    // Iterate through the decimated samples to find the maximum value.
    for (j = 1; j < (N/DEC_FACTOR); j = j + 1) begin
      if (decimated[j] > peak)
        peak = decimated[j];
    end
  end

  //-------------------------------------------------------------------------
  // Output Registration
  //-------------------------------------------------------------------------
  // The outputs are registered with one clock cycle latency.
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      valid_out   <= 1'b0;
      data_out    <= '0;
      peak_value  <= '0;
    end else if (valid_reg) begin
      valid_out   <= 1'b1;
      data_out    <= decimated_data;
      peak_value  <= peak;
    end
  end

endmodule