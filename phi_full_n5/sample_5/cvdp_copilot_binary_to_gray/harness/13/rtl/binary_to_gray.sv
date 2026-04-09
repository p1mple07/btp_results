module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  // Removed unused signal 'gray_out_d1'
  
  // Using combinational always block for the XOR logic
  always_comb begin
    gray_out = {binary_in[WIDTH-1], binary_in[WIDTH-2:0] ^ binary_in[WIDTH-2:0]} ;
  end

endmodule
