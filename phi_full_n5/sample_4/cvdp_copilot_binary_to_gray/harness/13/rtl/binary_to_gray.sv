module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Removed unused signal declaration

  always_comb begin // Replaced procedural assignment with combinational logic
    gray_out = binary_in; // Direct assignment to output
  end

  // Removed generate block, which was not needed and could cause multiple drivers
  // Replaced it with combinational logic for clarity and to remove potential multiple drivers
  assign gray_out[WIDTH-1] = binary_in[WIDTH-1];

  // Implementing Gray code conversion using combinational logic
  for (genvar i = 0; i < WIDTH - 1; i = i + 1) begin
    gray_out[i] = binary_in[i+1] ^ binary_in[i];
  end

endmodule
