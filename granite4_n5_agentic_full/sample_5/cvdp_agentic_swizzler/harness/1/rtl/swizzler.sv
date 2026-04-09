module swizzler (
    input wire [7:0] data_in,
    input wire [7:0] swizzle_map_flat [31:0] swizzle_map_flat,
    input wire [7:0] swizzle_map_flat,
    output logic [7:0] data_out
);

  always_comb begin
    if (bypass) begin
      data_out = data_in;
    end else begin
      data_out = data_in;
    end
  end

endmodule