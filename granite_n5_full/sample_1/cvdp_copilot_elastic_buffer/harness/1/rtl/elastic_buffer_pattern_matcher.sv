module elastic_buffer_pattern_matcher #(
   parameter WIDTH  = 16,
   parameter ERR_TOLERANCE  = 2
   )(
   input                         clk     , // clock input
   input                         rst     , // Active high synchronous reset
   input         [WIDTH-1:0]     i_data  , // input data to be matched
   input         [WIDTH-1:0]     i_pattern, // pattern to be matched against
   output logic                  o_match    // output indicating a match between the pattern and i_data.
);

   localparam MATCH_BITS = ERR_TOLERANCE+1;

   logic [MATCH_BITS-1:0] match_cnt;
   logic [WIDTH-1:0] xor_data;

   always_ff @(posedge clk or posedge rst) begin
      if (rst)
         match_cnt <= MATCH_BITS'{default:0};
      else
         match_cnt <= match_cnt + ($signed(i_data)^$signed(i_pattern))'(WIDTH'{default:0});
   end

   assign o_match = |(match_cnt[MATCH_BITS-1:MATCH_BITS-ERR_TOLERANCE-1]);

   function [$clog2(WIDTH)-1:0] ones_count;
      input [WIDTH-1:0] i_data;

      ones_count = $clog2(i_data)+1;
   endfunction

endmodule