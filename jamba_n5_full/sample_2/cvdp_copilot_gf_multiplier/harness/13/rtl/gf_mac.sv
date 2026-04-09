module gf_mac #(parameter WIDTH = 32) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);

    localparam num_segments = WIDTH / 8;
    reg [7:0] temp_result = 8'b0;

    genvar g;
    generate
        for (g = 0; g < num_segments; g++) begin : gen_multiplier
            wire [7:0] a_seg;
            wire [7:0] b_seg;
            assign a_seg = a[(8*g):(8*g+7)];
            assign b_seg = b[(8*g):(8*g+7)];
            assign seg_result = gf_multiplier(a_seg, b_seg);
            temp_result ^= seg_result;
        end
    endgenerate

    assign result = temp_result;
endmodule
