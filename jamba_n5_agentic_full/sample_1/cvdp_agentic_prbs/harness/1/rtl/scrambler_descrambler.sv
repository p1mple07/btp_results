module scrambler_descrambler #(
   parameter CHECK_MODE = 0,
   parameter POLY_LENGTH = 31,
   parameter POLY_TAP = 3,
   parameter WIDTH = 16
)(
   input         clk,
   input         rst,
   input         bypass_scrambling,
   input         data_in,
   output        data_out,
   output        valid_out,
   output        bit_count
);

logic [1:POLY_LENGTH] prbs [WIDTH:0];
logic [WIDTH-1:0] prbs_reg;
logic [WIDTH-1:0] prbs_xor_a, prbs_xor_b, prbs_msb, prbs_reg_next;

// Initialize prbs_reg to all 1's
initial begin
   for (int i = 0; i < WIDTH; i++)
      prbs_reg[i] = 1'b1;
end

// Shift register logic
always_ff @(posedge clk) begin
   if (rst) begin
      prbs_reg <= {WIDTH{1'b1}};
      data_out = {WIDTH{1'b1}};
      valid_out = 1'b1;
      bit_count = 0;
   end else begin
      prbs_reg <= prbs[WIDTH];
      data_out = prbs_xor_b;
      valid_out = 1'b0;
      bit_count = 0;
   end
end

always_ff @(posedge clk) begin
   if (rst) begin
      data_out <= {WIDTH{1'b0}};
      valid_out <= 1'b0;
      bit_count <= 0;
   end else begin
      data_out = data_in;
      valid_out = 1'b1;
      bit_count = bit_count + 1;
   end
end

always_ff @(posedge clk) begin
   if (bypass_scrambling) begin
      data_out = data_in;
      valid_out = 1'b1;
      bit_count = bit_count + 1;
   end else begin
      // scramble or descramble
      prbs_reg <= prbs[WIDTH];
      data_out = data_in ^ prbs_reg;
      valid_out = 1'b1;
      bit_count = bit_count + 1;
   end
end

endmodule
