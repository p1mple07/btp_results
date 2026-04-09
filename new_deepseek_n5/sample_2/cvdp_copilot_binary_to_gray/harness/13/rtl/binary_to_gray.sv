module binary_to_gray #(
    parameter WIDTH = 6
) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

  logic gray_out_next;  

  generate
    genvar i;
    for (i = 0; i < WIDTH - 1; i = i + 1) begin
      assign gray_out_next[i] = binary_in[i+1] ^ binary_in[i];
    end
  endgenerate

  always @posedge binary_in[0] begin
    gray_out_next = binary_in;
  end

  assign gray_out = gray_out_next;
endmodule