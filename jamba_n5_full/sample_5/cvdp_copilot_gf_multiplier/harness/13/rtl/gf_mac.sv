module gf_mac (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);

    local int i;
    reg [7:0] temp_result;
    reg [8:0] irreducible_poly = 9'b100011011;

    for (i = 0; i < WIDTH / 8; i++) begin
        reg [7:0] a_seg = a[(8*i) : 8*i + 8];
        reg [7:0] b_seg = b[(8*i) : 8*i + 8];

        reg [7:0] product = gf_multiplier(a_seg, b_seg);

        product = gf_reduce(product, irreducible_poly);

        temp_result ^= product;
    end

    result = temp_result;

endmodule
