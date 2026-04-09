module binary_to_gray #(
   parameter WIDTH = 6
) (
   input  wire [WIDTH-1:0] binary_in,
   output wire [WIDTH-1:0] gray_out
);

   logic gray_out_d1;  

   // Apply the XOR transformation to generate the Gray code output
   generate
      genvar i;
      for (i = 0; i < WIDTH - 1; i = i + 1) begin
         assign gray_out[i] = binary_in[i+1] ^ binary_in[i];
      end
   endgenerate

   always_ff @(posedge binary_in[0]) begin  
      // Update the Gray code output with the new input value
      gray_out <= binary_in;  
   end

endmodule