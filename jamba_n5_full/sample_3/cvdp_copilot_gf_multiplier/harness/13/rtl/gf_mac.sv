module gf_mac #(parameter WIDTH = 32) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);

    localparam num_segments = WIDTH / 8;
    reg [7:0] temp_result = 8'd0;

    genvar i;
    for (i = 0; i < num_segments; i = i + 1) begin : seg
        assign a_segment = a[(7 - 8*i):7];
        assign b_segment = b[(7 - 8*i):7];

        assign product = gf_multiplier(a_segment, b_segment);

        if (product >= 8'd10000000) begin
            product = product ^ irreducible_poly;
        end

        temp_result = temp_result ^ product;
    end

    assign result = temp_result;

endmodule
