module gf_mac #(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    output [7:0] result
);

    // Number of 8-bit segments is WIDTH/8
    genvar i;
    integer j;
    wire [7:0] seg_result [0:(WIDTH/8)-1];

    generate
        for (i = 0; i < (WIDTH/8); i = i + 1) begin : mac_segments
            // Extract the i-th 8-bit segment from a and b
            wire [7:0] a_seg = a[i*8 +: 8];
            wire [7:0] b_seg = b[i*8 +: 8];
            
            // Instantiate the 8-bit GF multiplier for the segment
            gf_multiplier u_gf_multiplier (
                .A(a_seg),
                .B(b_seg),
                .result(seg_result[i])
            );
        end
    endgenerate

    // Combine all segment results using XOR to perform the MAC operation
    reg [7:0] mac_result;
    always @(*) begin
         mac_result = 8'b0;
         for (j = 0; j < (WIDTH/8); j = j + 1)
             mac_result = mac_result ^ seg_result[j];
    end

    assign result = mac_result;

endmodule