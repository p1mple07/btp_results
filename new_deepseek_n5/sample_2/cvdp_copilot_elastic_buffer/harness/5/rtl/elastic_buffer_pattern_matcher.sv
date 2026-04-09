module elastic_buffer_pattern_matcher #(
    parameter int WIDTH        = 16,
    parameter int NUM_PATTERNS = 4
)(
    input  logic                              clk,
    input  logic                              rst,
    input logic                               i_valid,
    input  logic [WIDTH:0]                  i_data,
    input  logic [NUM_PATTERNS*WIDTH:0]     i_pattern,
    input  logic [NUM_PATTERNS*WIDTH:0]     i_mask,
    input  logic [$clog2(WIDTH+1)-1:0]        i_error_tolerance,
    output logic                              o_valid,
    output logic [NUM_PATTERNS-1:0]           o_match
);
   logic [1:0] o_valid_reg;
   logic [WIDTH-1:0] diff_pipe1 [NUM_PATTERNS-1:0];
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe2 [NUM_PATTERNS-1:0];
   logic [$clog2(WIDTH+1)-1:0] error_count_pipe3 [NUM_PATTERNS-1:0];

   always_ff @(posedge clk) begin
      if (rst) begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            diff_pipe1[j] <= '0;
         end
      end else begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            diff_pipe1[j] <= (i_data ^ i_pattern[j*WIDTH +: WIDTH]) & i_mask[j*WIDTH +: WIDTH];
         end
      end
   end

   always_ff @(posedge clk) begin
      if (rst) begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            error_count_pipe2[j] = '0;
         end
      end else begin
         for (int j = 0; j < NUM_PATTERNS; j++) begin
            error_count_pipe2[j] <= popcount(diff_pipe1[j]);
         end
      end
   end

   always_comb begin
      for (int j = 0; j < NUM_PATTERNS; j++) begin
         o_match[j] = (error_count_pipe2[j] <= i_error_tolerance);
      end
   end

   always_ff @(posedge clk) begin
      if (rst)
         {o_valid, o_valid_reg} <= '0;
      else
         {o_valid, o_valid_reg} <= {o_valid_reg, i_valid};
   end
endmodule