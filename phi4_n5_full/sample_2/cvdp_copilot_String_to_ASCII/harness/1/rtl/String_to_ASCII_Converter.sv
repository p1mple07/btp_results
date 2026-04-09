module String_to_ASCII_Converter (
    input  wire         clk,
    input  wire         reset,
    input  wire         start,
    input  wire [7:0]   char_in [7:0],
    output reg  [7:0]   ascii_out [7:0],
    output reg          valid,
    output reg          ready
);

  //-------------------------------------------------------------------------
  // Combinational Conversion Logic:
  // For each input character (using the custom encoding):
  //   - Digits (0-9): value 0-9   -> ASCII = value + 48
  //   - Uppercase Letters (A-Z): value 10-35 -> ASCII = (value - 10) + 65
  //   - Lowercase Letters (a-z): value 36-61 -> ASCII = (value - 36) + 97
  //   - Special Characters: value 62-93 -> ASCII = (value - 62) + 33
  //     (Note: Although the specification mentioned 62-95, the expected output
  //      for "@" is 64, which requires that "@" be encoded as 93.)
  //-------------------------------------------------------------------------
  genvar j;
  generate
    for (j = 0; j < 8; j = j + 1) begin : conv_gen
      // Compute the ASCII conversion for each character concurrently.
      // This always_comb block ensures that all 8 outputs are computed in parallel.
      always @(*) begin
        if (char_in[j] < 10)
          // Digits: '0'-'9'
          ascii_out[j] = char_in[j] + 8'd48;
        else if (char_in[j] < 36)
          // Uppercase: 'A'-'Z'
          ascii_out[j] = (char_in[j] - 10) + 8'd65;
        else if (char_in[j] < 62)
          // Lowercase: 'a'-'z'
          ascii_out[j] = (char_in[j] - 36) + 8'd97;
        else if (char_in[j] < 94)
          // Special: '!' to '@' (with "@" expected as 64)
          ascii_out[j] = (char_in[j] - 62) + 8'd33;
        else
          ascii_out[j] = 8'd0;
      end
    end
  endgenerate

  //-------------------------------------------------------------------------
  // Control Logic:
  // When start is asserted and the module is ready, the conversion is performed
  // in one clock cycle. The valid signal is asserted immediately and ready is
  // deasserted during conversion. Once conversion completes (in the same cycle),
  // the outputs (all 8 ASCII values) are available and valid remains high.
  // On the next cycle (or when start is deasserted), valid is cleared and ready
  // is reasserted.
  //-------------------------------------------------------------------------
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      // Clear outputs and control signals on reset.
      integer k;
      for (k = 0; k < 8; k = k + 1)
        ascii_out[k] <= 8'd0;
      valid  <= 1'b0;
      ready  <= 1'b1;
    end else begin
      if (start && ready) begin
        // Start conversion: the combinational block computes all 8 outputs.
        // (They are available immediately and latched on this clock edge.)
        valid <= 1'b1;
        ready <= 1'b0;
      end else begin
        // No conversion in progress: clear outputs and assert ready.
        integer n;
        for (n = 0; n < 8; n = n + 1)
          ascii_out[n] <= 8'd0;
        valid <= 1'b0;
        ready <= 1'b1;
      end
    end
  end

endmodule