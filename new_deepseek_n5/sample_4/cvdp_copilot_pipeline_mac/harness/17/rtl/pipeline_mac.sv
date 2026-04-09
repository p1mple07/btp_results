module pipeline_mac #(
    parameter DWIDTH = 16,
    parameter N = 4
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // Calculate accumulator width to handle potential overflow
  parameter DWIDTH_ACCUMULATOR = 2 * DWIDTH; // Sufficient width for accumulation

  logic [DWIDTH_ACCUMULATOR-1:0] mult_result_reg;
  logic [DWIDTH_ACCUMULATOR-1:0] accumulation_reg;
  logic [$clog2(N):0] counter;
  logic [$clog2(N):0] counter_reg;
  logic count_rst, accumulator_rst;

  always @(posedge clk or negedge rstn) begin
    // Multiplication stage
    if (valid_i & ~rstn) begin
      mult_result_reg = multiplicand * multiplier;
    end
    // Store intermediate result
    accumulation_reg = mult_result_reg;
  end

  always @(posedge clk or negedge rstn) begin
    // Accumulation stage
    if (valid_i & ~rstn) begin
      accumulation_reg = accumulation_reg + accumulation_reg;
    end
    // Store final result
    result = accumulation_reg;
  end

  always @(posedge clk or negedge rstn) begin
    // Counter logic
    counter = count_rst ? 'b1 : (valid_i & rstn ? (counter_reg + 'd1) : counter_reg);
    count_rst = valid_out_s1;
    accumulator_rst = valid_out_s1;
  end

  always @(posedge clk or negedge rstn) begin
    // Valid output logic
    valid_out_s0 = (counter_reg == N-1);
    valid_out_s1 = valid_out_s0 & ~valid_out_s2;
    valid_out_s2 = valid_out_s1 & ~valid_out;
    valid_out = valid_out_s1 & ~valid_out_s2;
  end

  assign result = accumulation_reg;
  assign valid_out = valid_out_s1 & ~valid_out_s2;
endmodule