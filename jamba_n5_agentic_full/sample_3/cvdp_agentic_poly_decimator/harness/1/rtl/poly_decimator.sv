`include "rtl/adder_tree.sv"
`include "rtl/shift_register.sv"
`include "rtl/coeff_ram.sv"
`include "rtl/poly_filter.sv"

module poly_decimator #(
  parameter TAPS = 8,
  parameter M = 4,
  parameter COEFF_WIDTH = 16,
  parameter DATA_WIDTH = 16
) (
  input  logic clk,
  input  logic arst_n,
  input  logic [DATA_WIDTH-1:0] in_sample [0: (TAPS * M - 1)],
  output logic [DATA_WIDTH-1:0] out_sample [0: TAPS-1]
);

  // --- Step 1: Shift Register Input Buffer ----------------------------------
  // Length = TOTAL_TAPS * M
  localparam INPUT_BUFFER_DEPTH = TAPS * M;
  wire [INPUT_BUFFER_DEPTH-1:0] in_buffer [0: INPUT_BUFFER_DEPTH-1];

  // Connect the input samples to the shift register
  initial begin
    for (int i = 0; i < INPUT_BUFFER_DEPTH; i++) begin
      in_buffer[i] = in_sample[i];
    end
  end

  // --- Step 2: Shift Register Forward Path --------------------------------
  shift_register #(.TAPS(TAPS), .DATA_WIDTH(DATA_WIDTH)) u_shift (
    .clk(clk),
    .arst_n(arst_n),
    .load(arst_n),
    .new_sample(in_buffer),
    .data_out(in_buffer),
    .data_out_val(true)
  );

  // --- Step 3: Polyphase Filter ---------------------------------------------
  poly_filter #(.M(M), .TAPS(TAPS), .COEFF_WIDTH(COEFF_WIDTH), .DATA_WIDTH(DATA_WIDTH)) u_filter (
    .clk(clk),
    .arst_n(arst_n),
    .sample_buffer(in_buffer),
    .phase(0),
    .filter_out(out_sample),
    .valid(valid_stage0)
  );

  // --- Step 4: Final Output Registration ------------------------------------
  // Store the last output of the filter into the output register
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      out_sample[0] <= out_sample[TAPS-1];
    end
  end

endmodule
