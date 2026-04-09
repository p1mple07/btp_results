module continuous_adder (
    input  logic                   clk,
    input  logic                   reset,
    input  logic [DATA_WIDTH-1:0]  data_in,
    input  logic                   data_valid,
    output logic [DATA_WIDTH-1:0]  sum_out,
    output logic                   sum_ready
);

   // Parameter declarations
   parameter int DATA_WIDTH         = 32;
   parameter int THRESHOLD_VALUE    = 100;
   parameter int SIGNED_INPUTS      = 1;

   // Internal accumulator: type depends on whether signed arithmetic is enabled.
   generate
      if (SIGNED_INPUTS) begin : signed_mode
         logic signed [DATA_WIDTH-1:0] sum_accum;
         always_ff @(posedge clk) begin
            if (reset) begin
               sum_accum <= '0;
               sum_ready <= 1'b0;
            end else begin
               if (data_valid) begin
                  sum_accum <= sum_accum + data_in;
                  if ((sum_accum >= THRESHOLD_VALUE) || (sum_accum <= -THRESHOLD_VALUE)) begin
                     sum_out   <= sum_accum;
                     sum_ready <= 1'b1;
                     sum_accum <= '0;
                  end else begin
                     sum_ready <= 1'b0;
                  end
               end
            end
         end
      end
      else begin : unsigned_mode
         logic [DATA_WIDTH-1:0] sum_accum;
         always_ff @(posedge clk) begin
            if (reset) begin
               sum_accum <= '0;
               sum_ready <= 1'b0;
            end else begin
               if (data_valid) begin
                  sum_accum <= sum_accum + data_in;
                  if (sum_accum >= THRESHOLD_VALUE) begin
                     sum_out   <= sum_accum;
                     sum_ready <= 1'b1;
                     sum_accum <= '0;
                  end else begin
                     sum_ready <= 1'b0;
                  end
               end
            end
         end
      end
   endgenerate

endmodule