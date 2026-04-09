module poly_decimator #(
  parameter M = 4,  // Decimation factor
  parameter TAPS = 8,  // Taps per phase
  parameter COEFF_WIDTH = 16,  // Coefficient bit width
  parameter DATA_WIDTH = 16,   // Sample data bit width
  localparam ACC_WIDTH = DATA_WIDTH + COEFF_WIDTH + $clog2(TAPS)
)
(
  input  logic                        _clk,
  input  logic                        _arst_n,
  input  logic [DATA_WIDTH-1:0]       sample_buffer [0:TAPS-1],
  input  logic                        _valid_in,
  input  logic [$clog2(M)-1:0]        phase,
  output logic [ACC_WIDTH-1:0]        filter_out,
  output logic                         valid
);

  // ---- Stage 0: Shift Register ----
  shift_register #(
    .clk(clk),
    .arst_n(arst_n),
    .load(load),
    .new_sample(sample_buffer),
    .data_out(data_out),
    .data_out_val(data_out_val)
  ) u_shift_reg (
    .data_out_val(1'b0),
    .data_out(data_out)
  );

  // ---- Stage 1: Coefficient RAM ----
  coeff_ram #(
    .NUM_COEFFS(M * TAPS),
    .DATA_WIDTH(COEFF_WIDTH)
  ) u_coeff_ram;

  // ---- Stage 2: Polyphase Filter ----
  poly_filter #(
    .M(M),
    .TAPS(TAPS),
    .COEFF_WIDTH(COEFF_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ACC_WIDTH(ACC_WIDTH)
  ) u_poly_filter (
    .input.sample_buffer(sample_buffer),
    .input.valid_in(valid_stage0),
    .input.phase(phase),
    .output.filter_out(filter_out),
    .output.valid(valid)
  );

  // ---- Stage 3: Adder Tree ----
  adder_tree #(
    .NUM_INPUTS(TAPS),
    .DATA_WIDTH(DATA_WIDTH + COEFF_WIDTH)
  ) u_adder_tree_filter (
    .input.data_in(products),
    .input.valid_in(valid_stage1),
    .sum_out(sum_result),
    .valid_out(valid_adder)
  );

  // ---- Overall Control Logic ----
  logic valid_stage0 = 1'b0;
  logic valid_stage1 = 1'b0;
  logic valid_adder = 1'b0;

  // ---- Event-Driven Architecture ----
  always_ff @(posedge clk or negedge arst_n) begin
    if (!arst_n) begin
      // Initialize all stages
      data_out_val <= 1'b0;
      valid_stage0 <= 1'b0;
      valid_stage1 <= 1'b0;
      valid_adder <= 1'b0;
    end
    else begin
      if (valid_in && !arst_n) begin
        // Stage 0 Initialization
        fill_shift_reg();

        // Stage 1 Coefficient Fetch
        if (valid_stage0) begin
          fetch_coefficients(phase);
        end

        // Stage 2 Multiply & Accumulate
        compute_products();

        // Stage 3 Sum Products
        accumulate_sums();
      end
    end
  end

  // ---- Helper Functions ----
  function void fill_shift_reg() @valid_start;
  function void fetch_coefficients(phase) @valid_start;
  function void compute_products() @valid_start;
  function void accumulate_sums() @valid_start;

  // ---- Data Assignment ----
  assign filter_out = sum_result;
  assign valid = valid_adder;
  assign data_out = data_out;
  assign data_out_val = data_out_val;