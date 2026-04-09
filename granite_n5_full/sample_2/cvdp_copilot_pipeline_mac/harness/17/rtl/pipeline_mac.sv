module pipeline_mac #(
    parameter DWIDTH = 16,  // Bit width for multiplicand and multiplier
    parameter N      = 4    // Number of data points to accumulate over
) (
    clk,
    rstn,
    multiplicand,
    multiplier,
    valid_i,
    result,
    valid_out
);
  // Insert code here to calculate parameter DWIDTH_ACCUMULATOR to handle the result bit width to avoid overflow.
  
  // Insert code here to perform the multiplication operation.
  
  // Insert code here to accumulate the results over N data points.
  
  // Insert code here to generate the output valid signal for the 2-stage pipeline.
  
  // Insert code here to register the valid output for the 2-stage pipeline.
  
  // Insert code here to generate the combinational assignments for the count, valid output, and result signals.

endmodule