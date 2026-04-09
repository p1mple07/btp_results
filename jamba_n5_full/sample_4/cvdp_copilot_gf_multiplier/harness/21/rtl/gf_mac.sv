
module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result // 8-bit XORed result of all GF multiplications
);
