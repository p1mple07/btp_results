module advanced_decimator_with_adaptive_peak_detection #(
  parameter int unsigned N = 8,
  parameter int unsigned DATA_WIDTH = 16,
  parameter int unsigned DEC_FACTOR = 4
)(
  // Clock and Reset
  input wire clk,
  input wire reset,

  // Input Interface
  input wire valid_in,
  input wire [DATA_WIDTH*N-1:0] data_in,

  // Output Interface
  output wire valid_out,
  output wire [DATA_WIDTH*(N/DEC_FACTOR)-1:0] data_out,
  output wire [DATA_WIDTH-1:0] peak_value
);

  // Define registers and variables here
  reg [DATA_WIDTH*N-1:0] data_reg;
  reg [DATA_WIDTH-1:0] peak_reg;
  wire [DATA_WIDTH-(N%DEC_FACTOR):0] data_unpacked[N/DEC_FACTOR];
  wire [DATA_WIDTH-1:0] data_packed[(N/DEC_FACTOR)*DEC_FACTOR-1:0];
  wire [DATA_WIDTH-1:0] max_sample;
  wire [N/DEC_FACTOR-1:0] sel_samples;

  // Register input data
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_reg <= '0;
    end else begin
      data_reg <= data_in;
    end
  end

  // Unpack input data
  assign data_unpacked = data_reg[DATA_WIDTH*N-1:DATA_WIDTH*N/DEC_FACTOR];

  // Decimate the data
  generate
    genvar i;
    for (i=0; i<N/DEC_FACTOR; i++) begin : decimate_loop
      assign sel_samples[i] = (i % DEC_FACTOR) == 0? data_unpacked[i/DEC_FACTOR][DATA_WIDTH-1:0] : data_unpacked[i/DEC_FACTOR][DATA_WIDTH-(N%DEC_FACTOR)+i%DEC_FACTOR-1:DATA_WIDTH-(N%DEC_FACTOR)];
    end
  endgenerate

  // Calculate the peak value
  assign max_sample = sel_samples[0];
  generate
    genvar j;
    for (j=1; j<N/DEC_FACTOR; j++) begin : max_value_search
      assign max_sample = (max_sample > sel_samples[j])? max_sample : sel_samples[j];
    end
  endgenerate

  // Pack the decimated data
  assign data_packed = {max_sample, sel_samples[N/DEC_FACTOR-1]};

  // Generate output signals
  assign valid_out = valid_in && (sel_samples!= '0);
  assign data_out = data_packed;
  assign peak_value = max_sample;

endmodule