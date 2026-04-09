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
  // Calculate accumulator bit width
  parameter DWIDTH_ACCUMULATOR = 32;

  // Stage 1: Multiplication
  always @(posedge clk or negedge rstn) begin
      if (valid_i & ~rstn) begin
          mult_result_reg = multiplicand * multiplier;
      end
  end

  // Stage 2: Accumulation
  always @(posedge clk or negedge rstn) begin
      if (valid_i & ~rstn) begin
          accumulation_reg = accumulation_reg + mult_result_reg;
      end
  end

  // Counter for accumulation count
  always @(posedge clk or negedge rstn) begin
      if (valid_i & ~rstn) begin
          counter = counter + 1;
      end else if (rstn) begin
          counter = 0;
      end
  end

  // Register valid output
  always @(posedge clk or negedge rstn) begin
      valid_out_s0 = (counter == N-1);
      valid_out_s1 = (counter == N);
  end

  // Combinational assignments
  assign counter = count_rst ? 'b1 : (valid_i & rstn ? (counter_reg + 'd1) : counter_reg);
  assign valid_out_s0 = (counter_reg == N-1);
  assign count_rst = valid_out_s1;
  assign accumulator_rst = valid_out_s1;
  assign result = accumulation_reg;
  assign valid_out = valid_out_s1 & ~valid_out_s2;
endmodule