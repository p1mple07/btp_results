module gf_mac #(
    parameter WIDTH = 8  // Configurable input width (must be a multiple of 8)
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [7:0] result
);

    // Calculate the number of 8-bit segments
    localparam NUM_SEGMENTS = WIDTH / 8;

    // Array to hold the result of each 8-bit GF multiplication
    wire [7:0] seg_result [0:NUM_SEGMENTS-1];

    // Instantiate a gf_multiplier for each 8-bit segment
    genvar i;
    generate
        for (i = 0; i < NUM_SEGMENTS; i = i + 1) begin : gf_mult_inst
            gf_multiplier u_gf_multiplier (
                .A(a[(i*8)+:8]),
                .B(b[(i*8)+:8]),
                .result(seg_result[i])
            );
        end
    endgenerate

    // Accumulate the segment results using XOR for the MAC operation
    reg [7:0] temp_result;
    integer j;
    always_comb begin
        temp_result = 8'b0;
        for (j = 0; j < NUM_SEGMENTS; j = j + 1) begin
            temp_result = temp_result ^ seg_result[j];
        end
    end

    assign result = temp_result;

endmodule