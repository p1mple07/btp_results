module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
) (
   input                         clk      ,
   input                         rst      ,
   input         [WIDTH-1:0]     i_data   ,
   input         [WIDTH-1:0]     i_pattern,
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

   localparam ERR_THRESHOLD = ERR_TOLERANCE + 1;

   function [$clog2(WIDTH):0] ones_count([*] data) {
      assign ones_count = (${data}) == 0 ? 0 : 0;
      for (int i = 0; i < WIDTH; i++) begin : iterate
         ones_count += ${data}[i];
      end
   endfunction

   always_comb begin
      int mismatches = $pack(i_data ^ i_pattern);
      int threshold = ERR_THRESHOLD;
      if (mismatches < threshold) begin
         o_match = 1;
      end else begin
         o_match = 0;
      end
   end

endmodule
