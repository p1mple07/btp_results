module gf_mac #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [7:0] result
);

    // Calculate number of 8-bit segments (WIDTH must be a multiple of 8)
    localparam NUM_SEGMENTS = WIDTH / 8;

    // Array to hold the result of each 8-bit GF multiplication
    wire [7:0] mult_results [0:NUM_SEGMENTS-1];

    // Instantiate a gf_multiplier for each 8-bit segment
    genvar i;
    generate
        for (i = 0; i < NUM_SEGMENTS; i = i + 1) begin : mac_instances
            // Extract the i-th 8-bit segment from a and b (LSB first)
            gf_multiplier u_gf_multiplier (
                .A(a[8*i + 7:8*i]),
                .B(b[8*i + 7:8*i]),
                .result(mult_results[i])
            );
        end
    endgenerate

    // Cumulative XOR of all segment multiplication results
    reg [7:0] temp_result;
    always_comb begin
        temp_result = 8'b0;
        integer j;
        for (j = 0; j < NUM_SEGMENTS; j = j + 1) begin
            temp_result = temp_result ^ mult_results[j];
        end
    end

    assign result = temp_result;

endmodule