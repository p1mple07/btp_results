module advanced_decimator_with_adaptive_peak_detection #(
  parameter int N = 8, // Total number of input samples
  parameter int DATA_WIDTH = 16, // Bit-width of each sample
  parameter int DEC_FACTOR = 4 // Decimation factor
) (
  input clk, // Clock signal, active on the rising edge
  input reset, // Asynchronous reset, active high
  input valid_in, // Input validation signal indicating valid data
  input [DATA_WIDTH * N - 1:0] data_in, // Packed input data (N samples of integer signed values)
  output reg valid_out, // Output validation signal, indicating valid decimated data
  output reg [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_out, // Packed decimated output data, containing (N / DEC_FACTOR) samples, each of size DATA_WIDTH
  output reg [DATA_WIDTH - 1:0] peak_value // Peak value among the decimated samples, with a size of DATA_WIDTH
);

  reg [DATA_WIDTH * N - 1:0] data_reg; // Input data register
  reg [N - 1:0] sel_reg; // Selection register
  wire [DATA_WIDTH * (N / DEC_FACTOR) - 1:0] data_pack; // Packed decimated data
  wire [(N / DEC_FACTOR) - 1:0] peak_index; // Index of the peak value
  wire [DATA_WIDTH - 1:0] peak_sample; // Peak value among the decimated samples

  assign valid_out = valid_in & (~reset); // Generate output validation signal based on input validation and reset signal

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_reg <= 'b0; // Clear input data register when reset is active
      sel_reg <= 'b0; // Clear selection register when reset is active
    end else begin
      data_reg <= data_in; // Register input data on the rising edge of the clock
    end
  end

  generate
    if (N % DEC_FACTOR!= 0) begin : gen_error
      $display("Error: Invalid decimation factor");
    end else begin : gen_correct
      always @(*) begin
        sel_reg <= ((sel_reg + 1) < DEC_FACTOR)? (sel_reg + 1) : 'd0; // Increment selection register on the rising edge of the clock
        data_pack[DATA_WIDTH * sel_reg : DATA_WIDTH * (sel_reg + 1) - 1] <= data_reg[(sel_reg * DATA_WIDTH) +: DATA_WIDTH]; // Pack decimated data samples into a single bus
      end

      assign peak_index = sel_reg / DEC_FACTOR; // Calculate index of the peak value
      assign peak_sample = data_pack[peak_index * DATA_WIDTH : (peak_index + 1) * DATA_WIDTH - 1]; // Select peak value from packed data bus
      assign peak_value = peak_sample; // Assign peak value to output port
    end
  endgenerate

endmodule