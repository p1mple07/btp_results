Module information */
module scrambler_descrambler #(
   parameter POLY_LENGTH = 31,
   parameter POLY_TAP   = 3,
   parameter WIDTH      = 16,
   parameter CHECK_MODE = 0
)(
   input     clk,
   input     rst,
   input     bypass_scrambling,
   input     data_in,
   input     valid_in,
   output    data_out,
   output    valid_out,
   output    bit_count
);

/* State variables */
local_state reg states = 0;
local logic reg [WIDTH-1:0] prbs_out;

/* PRBS generation and XOR */
generate
  include "prbs_gen_check" #(
     CHECK_MODE,
     POLY_LENGTH,
     POLY_TAP,
     WIDTH
  );
  wire prbs_gen_check.data_out to prbs_out;

  if (!bypass_scrambling) {
     generate #+latency(1)
     xor_data: data_out <= data_in ^ prbs_out;
  } else {
     wire data_out <= data_in;
  }
endgenerate

/* Bit count tracking */
always_ff @ (posedge clk) begin
   if (valid_in && !bypass_scrambling) begin
      bit_count <= bit_count + 1;
   end else if (valid_in && bypass_scrambling) begin
      bit_count <= bit_count;
   end
end

/* Reset handling */
always @* begin
   if (rst) begin
      states = 0;
      prbs_gen_check.reset();
   end else if (states == 1) begin
      states = 2;
   end
end

/* Clock gating */
always_ff @ (posedge clk) gated_clock <= !rst;

endmodule