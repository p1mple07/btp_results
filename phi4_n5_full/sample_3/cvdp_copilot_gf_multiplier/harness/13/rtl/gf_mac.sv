module gf_mac #(parameter WIDTH = 8) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [7:0] result
);

    // Ensure WIDTH is a multiple of 8
    generate
        if (WIDTH % 8 != 0) begin
            initial $error("WIDTH parameter must be a multiple of 8");
        end
    endgenerate

    localparam integer NUM_SEGMENTS = WIDTH / 8;
    wire [7:0] seg_result [0:NUM_SEGMENTS-1];

    genvar i;
    generate
        for (i = 0; i < NUM_SEGMENTS; i = i + 1) begin : mac_gen
            gf_multiplier u_gf_multiplier (
                .A(a[(i*8)+7 -: 8]),
                .B(b[(i*8)+7 -: 8]),
                .result(seg_result[i])
            );
        end
    endgenerate

    // XOR all segment results to form the final MAC result
    assign result = ^{ seg_result };

endmodule