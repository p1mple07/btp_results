module advanced_decimator_with_adaptive_peak_detection #
  (
   parameter N              = 8,          // Total number of input samples
   parameter DATA_WIDTH     = 16,         // Bit-width of each sample
   parameter DEC_FACTOR     = 4           // Decimation factor (must divide N)
   )
  (
   input  logic                      clk,
   input  logic                      reset,
   input  logic                      valid_in,
   // Packed input: N samples of signed DATA_WIDTH bits (sample0 is the leftmost)
   input  signed [DATA_WIDTH*N-1:0]  data_in,
   output logic                      valid_out,
   // Packed output: (N/DEC_FACTOR) decimated samples
   output signed [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
   // Peak value among the decimated samples
   output signed [DATA_WIDTH-1:0]   peak_value
   );

  //-------------------------------------------------------------------------
  // Internal registers and wires
  //-------------------------------------------------------------------------
  // Register to hold the input data (one pipeline stage)
  reg [DATA_WIDTH*N-1:0] data_reg;
  reg                     valid_data;  // Registered copy of valid_in

  // Intermediate combinational results: decimated output and peak value
  wire [DATA_WIDTH*(N/DEC_FACTOR)-1:0] decimated_out;
  wire signed [DATA_WIDTH-1:0]         peak_value_comb;

  // Registered outputs: decimated data and peak value
  reg [DATA_WIDTH*(N/DEC_FACTOR)-1:0] decimated_reg;
  reg signed [DATA_WIDTH-1:0]         peak_reg;

  //-------------------------------------------------------------------------
  // 1. Input Data Registering
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_reg      <= '0;
      valid_data    <= 1'b0;
    end else begin
      if (valid_in) begin
        data_reg      <= data_in;
        valid_data    <= 1'b1;
      end else begin
        valid_data    <= 1'b0;
      end
    end
  end

  //-------------------------------------------------------------------------
  // 2. Decimation and Peak Detection (Combinational Logic)
  //-------------------------------------------------------------------------
  // This block unpacks the registered input data, selects one sample per DEC_FACTOR,
  // and computes the peak value among the decimated samples.
  always_comb begin
    int i;
    // Temporary array to hold decimated samples
    logic signed [DATA_WIDTH-1:0] decimated [0:(N/DEC_FACTOR)-1];
    
    // Decimation: for each index, select sample at position i*DEC_FACTOR.
    // Note: data_reg is packed as {sample0, sample1, ..., sample[N-1]}.
    for (i = 0; i < N/DEC_FACTOR; i++) begin
      // Extract sample: sample index = i*DEC_FACTOR.
      // Slicing: the leftmost DATA_WIDTH bits correspond to sample0.
      decimated[i] = data_reg [ ((i+1)*DEC_FACTOR*DATA_WIDTH)-1 -: DATA_WIDTH ];
    end

    // Peak Detection: find the maximum value among decimated samples.
    logic signed [DATA_WIDTH-1:0] peak;
    peak = decimated[0];
    for (i = 1; i < N/DEC_FACTOR; i++) begin
      if (decimated[i] > peak)
        peak = decimated[i];
    end

    // Pack the decimated samples into a temporary vector.
    // The samples are packed in order: decimated[0] becomes the most significant.
    logic signed [DATA_WIDTH*(N/DEC_FACTOR)-1:0] temp_decimated;
    for (i = 0; i < N/DEC_FACTOR; i++) begin
      temp_decimated [ ((N/DEC_FACTOR)-1-i)*DATA_WIDTH +: DATA_WIDTH ] = decimated[i];
    end

    decimated_out    = temp_decimated;
    peak_value_comb  = peak;
  end

  //-------------------------------------------------------------------------
  // 3. Output Registering (Pipeline Stage)
  //-------------------------------------------------------------------------
  // Register the combinational results to achieve a 1-cycle pipeline latency.
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      decimated_reg <= '0;
      peak_reg      <= '0;
      valid_out     <= 1'b0;
    end else if (valid_data) begin
      decimated_reg <= decimated_out;
      peak_reg      <= peak_value_comb;
      valid_out     <= 1'b1;
    end else begin
      valid_out     <= 1'b0;
    end
  end

  //-------------------------------------------------------------------------
  // 4. Output Assignment
  //-------------------------------------------------------------------------
  assign data_out   = decimated_reg;
  assign peak_value = peak_reg;

endmodule