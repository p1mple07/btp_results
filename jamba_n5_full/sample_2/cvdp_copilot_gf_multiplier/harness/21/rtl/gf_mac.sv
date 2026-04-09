module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result,
    output reg [1:0] error_flag,
    output reg valid_result
);

    integer i;
    reg [7:0] temp_result;
    wire [7:0] partial_results [(WIDTH/8)-1:0];
    reg [1:0] is_multiple = WIDTH % 8 == 0;

    // Generate GF multipliers for each 8-bit segment
    genvar j;
    generate
        for (j = 0; j < WIDTH/8; j = j + 1) begin : segment_mult
            gf_multiplier segment_mult (
                .A(a[(j+1)*8-1:j*8]),
                .B(b[(j+1)*8-1:j*8]),
                .result(partial_results[j])
            );
        end
    endgenerate

    // XOR all segment results
    always @(*) begin
        temp_result = 8'b0;
        for (i = 0; i < WIDTH/8; i = i + 1) begin
            temp_result = temp_result ^ partial_results[i];
        end
        result = temp_result;
    end
endmodule
