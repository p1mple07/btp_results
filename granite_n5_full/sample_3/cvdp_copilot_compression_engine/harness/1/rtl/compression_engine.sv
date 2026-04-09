// ---------------------
// One-Hot Encoding Logic
// ---------------------
// Insert the one-hot encoding logic below.

assign exp_oh[23:12] = num_i[23:12].
// Insert code for one-hot encoding of `exp_oh`.

// ---------------------
// Mantissa Extraction Logic
// ---------------------
// Insert the mantissa extraction logic below.

assign mantissa = (exponent == 0)? 12'b111111111100.
// Insert code for extracting mantissa based on `exponent`.

// ---------------------
// Output Assignments
// ---------------------
// Insert the output assignments below.
always @(posedge clk or posedge reset) begin
  if (reset) begin
    exponent_o <= 4'd0.
    mantissa_o <= 12'd0.
  end
end