module advanced_decimator_with_adaptive_peak_detection #(
  parameter int N           = 8,         // Total number of input samples
  parameter int DATA_WIDTH   = 16,        // Bit-width of each sample
  parameter int DEC_FACTOR   = 4          // Decimation factor (must divide N)
) (
  input  logic                  clk,
  input  logic                  reset,
  input  logic                  valid_in,
  input  logic [DATA_WIDTH*N-1:0] data_in,
  output logic                  valid_out,
  output logic [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
  output logic signed [DATA_WIDTH-1:0] peak_value
);

  // Local parameter for the number of decimated samples
  localparam int NUM_DEC = N / DEC_FACTOR;

  // Register to hold the unpacked input samples
  logic signed [DATA_WIDTH-1:0] sample_reg [0:N-1];

  // Registered valid signal
  logic valid_reg;

  // Combinationally computed decimated samples and peak value
  logic signed [DATA_WIDTH-1:0] decimated [0:NUM_DEC-1];
  logic signed [DATA_WIDTH-1:0] peak;

  // Packed bus for the decimated data output
  logic [DATA_WIDTH*NUM_DEC-1:0] decimated_packed;

  // -------------------------------------------------------------------
  // Input Data Registering and Unpacking
  // -------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // Clear all sample registers on reset
      for (int i = 0; i < N; i++) begin
        sample_reg[i] <= '0;
      end
      valid_reg <= 1'b0;
    end else if (valid_in) begin
      // Unpack the packed input bus into individual samples
      for (int i = 0; i < N; i++) begin
        sample_reg[i] <= data_in[((i+1)*DATA_WIDTH)-1 -: DATA_WIDTH];
      end
      valid_reg <= valid_in;
    end
  end

  // -------------------------------------------------------------------
  // Decimation and Peak Detection (Combinational Logic)
  // -------------------------------------------------------------------
  always_comb begin
    // Decimation: select one sample for every DEC_FACTOR samples.
    // The j-th decimated sample is taken from sample_reg[j*DEC_FACTOR].
    for (int j = 0; j < NUM_DEC; j++) begin
      decimated[j] = sample_reg[j * DEC_FACTOR];
    end

    // Peak Detection: find the maximum value among the decimated samples.
    peak = decimated[0];
    for (int j = 1; j < NUM_DEC; j++) begin
      if (decimated[j] > peak)
        peak = decimated[j];
    end

    // Pack the decimated samples into a single bus.
    // The first decimated sample becomes the most significant portion.
    decimated_packed = '0;
    for (int j = NUM_DEC - 1; j >= 0; j--) begin
      decimated_packed = { decimated[j], decimated_packed };
    end
  end

  // -------------------------------------------------------------------
  // Output Packing and Registration (1-cycle Latency)
  // -------------------------------------------------------------------
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      valid_out   <= 1'b0;
      data_out    <= '0;
      peak_value  <= '0;
    end else begin
      valid_out   <= valid_reg;
      data_out    <= decimated_packed;
      peak_value  <= peak;
    end
  end

endmodule