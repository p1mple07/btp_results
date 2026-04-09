module gf_mac #(
    parameter WIDTH = 32  // Input width, should be a multiple of 8
)(
    input [WIDTH-1:0] a,  // Multiplicand
    input [WIDTH-1:0] b,  // Multiplier
    output reg [7:0] result // 8-bit XORed result of all GF multiplications
);

    output reg error_flag;
    output reg valid_result;

    integer i;
    reg [7:0] temp_result;
    wire [7:0] partial_results [(WIDTH/8)-1:0];

    // Determine error and validity based on WIDTH
    assign error_flag = (WIDTH % 8) != 0 ? 1 : 0;
    assign valid_result = (WIDTH % 8) == 0 ? 1 : 0;

    // If the width is valid, proceed with the standard GF multiplication
    if (WIDTH % 8 == 0) begin
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

        // Set valid_result and error_flag
        assign valid_result = (WIDTH % 8) == 0 ? 1 : 0;
        assign error_flag = (WIDTH % 8) != 0 ? 1 : 0;
    end else
    {
        // Set error and valid to 0
        assign error_flag = 1;
        assign valid_result = 0;
        assign result = 8'b0;
    }

endmodule
