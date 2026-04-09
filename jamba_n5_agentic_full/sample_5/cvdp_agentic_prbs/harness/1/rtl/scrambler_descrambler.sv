module scrambler_descrambler (#(
   parameter CHECK_MODE = 0,
   parameter POLY_LENGTH = 31,
   parameter POLY_TAP = 3,
   parameter WIDTH = 16
)) (
   input         clk,
   input         rst,
   input         bypass_scrambling,
   input         data_in,
   input         valid_in,
   output        data_out,
   output        valid_out,
   output bit_count
);

// Instantiate the prbs_gen_check module with default parameters
localparam CHECK_MODE_DEFAULT = 0;
localparam POLY_LENGTH_DEFAULT = 31;
localparam POLY_TAP_DEFAULT = 3;
localparam WIDTH_DEFAULT = 16;

prbs_gen_check uut #(.CHECK_MODE(CHECK_MODE_DEFAULT), .POLY_LENGTH(POLY_LENGTH_DEFAULT), .POLY_TAP(POLY_TAP_DEFAULT), .WIDTH(WIDTH_DEFAULT)) uut_inst (
   .clk(clk),
   .rst(rst),
   .bypass_scrambling(bypass_scrambling),
   .data_in(data_in),
   .data_out(data_out),
   .valid_in(valid_in),
   .valid_out(valid_out),
   .bit_count(bit_count)
);

always_ff @(posedge clk) begin
   if (rst) begin
      uut_inst.prbs_reg <= {POLY_LENGTH_DEFAULT{1'b1}};
      data_out <= {WIDTH_DEFAULT{1'b1}};
   end else begin
      uut_inst.prbs_reg <= prbs[WIDTH_DEFAULT];
      data_out <= prbs_xor_b;
   end
end

endmodule
