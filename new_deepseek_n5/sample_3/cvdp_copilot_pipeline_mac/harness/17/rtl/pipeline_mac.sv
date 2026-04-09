module pipeline_mac #(
    parameter DWIDTH = 16,
    parameter N      = 4
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // Calculate accumulator width
  parameter DWIDTH_ACCUMULATOR = (N+1)*DWIDTH;

  // Stage 1: Multiplication
  always @(posedge clk or negedge rstn) begin
     if (valid_i & ~rstn) begin
        mult_result_reg = multiplicand * multiplier;
     end
  end

  // Stage 2: Accumulation
  always @(posedge clk or negedge rstn) begin
     if (valid_i & ~rstn & mult_result_reg != 0) begin
        accumulation_reg = accumulation_reg + mult_result_reg;
     end
     valid_out_s1 = accumulation_reg != 0;
  end

  // Counter for tracking accumulations
  always @(posedge clk or negedge rstn) begin
     if (valid_i & ~rstn) counter = counter + 1;
     else counter = 0;
  end

  // Register valid output
  always @(posedge clk or negedge rstn) begin
     if (valid_i & ~rstn) valid_out_s0 = 1;
     if (counter == N-1) valid_out_s1 = 1;
     if (valid_out_s1 & ~valid_out_s2) valid_out = 1;
  end

  // Reset signals
  count_rst = valid_out_s1;
  accumulator_rst = valid_out_s1;

  // Final assignments
  assign result = accumulation_reg;
  assign valid_out = valid_out_s1 & ~valid_out_s2;
endmodule