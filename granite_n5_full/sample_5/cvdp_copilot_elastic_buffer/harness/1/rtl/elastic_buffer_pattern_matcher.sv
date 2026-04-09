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

logic [WIDTH-1:0] xor_data;
logic [1:0] err_count;

assign xor_data = i_data ^ i_pattern;

always_comb begin
   err_count        = {err_count[0], $onehot0(xor_data)};
   
end

assign o_match = |err_count? 1'b0 : 1'b1;

endmodule