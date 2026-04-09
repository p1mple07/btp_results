module poly_decimator #(
  parameter M           = 4,    // Decimation factor
  parameter TAPS        = 8,    // Taps per phase
  parameter COEFF_WIDTH = 16,   // Coefficient bit width
  parameter DATA_WIDTH  = 16,   // Sample data bit width
  localparam ACC_WIDTH   = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS)
)
(
  input  logic                        clk,
  input  logic                        arst_n,
  input  logic [DATA_WIDTH-1:0]       sample_buffer [0:TAPS-1],
  input  logic                        valid_in,
  input  logic [$clog2(M)-1:0]        phase,
  output logic [ACC_WIDTH-1:0]        filter_out,
  output logic                        valid
);

  // ---- Core Components ----
  // 1. Shift Register for capturing samples
  shift_register #(
    parameter TAPS  = TAPS,
    parameter DATA_WIDTH  = DATA_WIDTH
  ) u_shift_reg (
    .clk(clk),
    .arst_n(arst_n),
    .load,
    .new_sample(sample_buffer),
    .data_out(data_out),
    .data_out_val(valid_shift)
  );

  // 2. Coefficient RAM for storing filter coefficients
  coeff_ram #(
    parameter NUM_COEFFS  = TAPS*M,
    parameter DATA_WIDTH  = COEFF_WIDTH
  )
  u_coeff_ram (
    .clk(clk),
    .addr(phase * TAPS + ($clog2(M))'s($clog2(M))),
    .data_out(coeff)
  );

  // 3. Polyphase Filter implementation
  poly_filter #(
    parameter M           = M,
    parameter TAPS        = TAPS,
    DATA_WIDTH         = DATA_WIDTH,
    COEFF_WIDTH        = COEFF_WIDTH
  ) u_poly_filter (
    .clk(clk),
    .arst_n(arst_n),
    .valid_in(valid_shift),
    .phase,
    .filter_out(filter_out),
    .valid_out(valid)
  );

  // 4. Adder Tree for summation
  adder_tree #(
    parameter NUM_INPUTS = TAPS,
    parameter DATA_WIDTH = DATA_WIDTH + COEFF_WIDTH
  ) u_adder_tree (
    .clk(clk),
    .arst_n(arst_n),
    .valid_in(valid_poly_filter),
    .data_in  (products),
    .sum_out  (filter_out),
    .valid_out(valid)
  );