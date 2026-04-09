module matrix_multiplier #(
  parameter ROW_A             = 4,
  parameter COL_A             = 4,
  parameter ROW_B             = 4,
  parameter COL_B             = 4,
  parameter INPUT_DATA_WIDTH  = 8,
  parameter OUTPUT_DATA_WIDTH = (INPUT_DATA_WIDTH * 2) + $clog2(COL_A)
) (
  input  logic                       clk,
  input  logic                       srst,
  input  logic                       valid_in,
  input  logic [ (ROW_A*COL_A*INPUT_DATA_WIDTH)-1:0] matrix_a,
  input  logic [ (ROW_B*COL_B*INPUT_DATA_WIDTH)-1:0] matrix_b,
  output logic                     valid_out,
  output logic [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] matrix_c
);

  // Modular constants for binary reduction
  localparam logic signed MODIFIED_COL_A   = COL_A;
  localparam logic signed HALF_MODIFIED_COL_A = MODIFIED_COL_A / 2;

  // Multiplier internal registers
  reg [COL_A:0] valid_out_reg;
  reg [(ROW_A*COL_B*OUTPUT_DATA_WIDTH)-1:0] mult_stage;
  reg [(ROW_A*COL_B*COL_A*OUTPUT_DATA_WIDTH)-1:0] add_stage;

  // Pipeline control signals
  logic srst_n;
  always_comb
    srst_n = !srst;

  // Synchronous reset handling
  always_comb
    valid_out = ~srst_n & valid_in;
  always_comb
    valid_out_reg = ~srst_n & valid_out;

  // Multiplication stage – unchanged
  always_ff @(posedge clk)
    if (srst)
      mult_stage <= {{{~valid_out_reg}}}';
    else
      mult_stage <= matrix_a[(((COL_A+COL_A-1)/2)*OUTPUT_DATA_WIDTH+:OUTPUT_DATA_WIDTH)];

  // Accumulation stage (binary tree)
  always_ff @(posedge clk)
    if (srst_n) begin
      mult_stage <= {{{~valid_out_reg}}}';
      add_stage <= {{{~valid_out_reg}}}';
    end else if (valid_out_reg[COL_A]) begin
      // First level of the binary tree
      for (int i = 0; i < COL_A/2; i++) begin: pair_acc
        mult_stage[((i*2)+:COL_A)] <= mult_stage[((i*2)+:COL_A)] + mult_stage[((i*2)+COL_A):((i*2)+COL_A+COL_A)];
      end

      // Second level (halving the active pairs)
      for (int i = 0; i < COL_A/4; i++) begin: pair_acc
        add_stage[((i*2)+:COL_A)] <= add_stage[((i*2)+:COL_A)] + add_stage[((i*2)+COL_A):((i*2)+COL_A+COL_A)];
      end

      // Final level (the remaining two elements)
      if (COL_A & 1) begin
        mult_stage[((COL_A/2)+:COL_A)] <= mult_stage[((COL_A/2)+:COL_A)] + mult_stage[((COL_A/2)+COL_A):((COL_A/2)+COL_A+COL_A)];
      end
    end

  // Output stage – after the final accumulation cycle
  always_ff @(posedge clk)
    if (srst_n) begin
      matrix_c <= {{{~valid_out_reg}}}';
    end else begin
      matrix_c <= add_stage[((COL_A*COL_B*OUTPUT_DATA_WIDTH)-1:0)];
    end

endmodule
