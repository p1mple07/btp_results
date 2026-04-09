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

  // Insert code here to define the input and output ports of the module.

  // Insert code here to declare internal signals and registers.

  // Insert code here for the multiplication stage using always @* block.

  // Insert code here for the accumulation stage using always @* block.

  // Insert code here for the N-bit counter using always @* block.

  // Insert code here for the registration of valid output for 2-stage pipeline using always @* block.

  // Insert code here for combinational assignments to generate the final result and valid output signals.

endmodule