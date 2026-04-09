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
  // Calculate accumulator width to handle N multiplications
  parameter DWIDTH_ACCUMULATOR = DWIDTH + log2(N);
  
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
  
  // Counter for tracking accumulation count
  always @(posedge clk or negedge rstn) begin
     if (valid_i & ~rstn) begin
         counter = counter + 1;
     end
  end
  
  // Valid output signals
  always @(posedge clk or negedge rstn) begin
     valid_out_s0 = (counter == N-1);
     valid_out_s1 = (counter == N);
     valid_out_s2 = (counter == N+1);
  end
  
  // Final result and valid output assignment
  always @(posedge clk or negedge rstn) begin
     if (rstn) begin
         result = 0;
         valid_out = 0;
     else if (valid_out_s1) begin
         result = accumulation_reg;
         valid_out = 1;
     else if (valid_out_s2) begin
         result = accumulation_reg;
         valid_out = 1;
     else begin
         result = accumulation_reg;
         valid_out = 0;
     end
  end
endmodule