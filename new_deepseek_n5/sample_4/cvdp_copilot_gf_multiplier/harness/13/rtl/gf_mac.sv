module gf_mac (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);
    parameter WIDTH = 32;
    reg [7:0] temp_result = 0;
    reg [8:0] multiplicand;
    reg [8:0] irreducible_poly = 9'b100011011;
    integer i;
    
    for (i = 0; i < WIDTH/8; i = i + 1) begin
        // Extract current 8-bit segments
        a_segment = (a >> (i*8)) & 0xFF;
        b_segment = (b >> (i*8)) & 0xFF;
        
        // Perform multiplication
        temp_result = temp_result ^ gf_multiplier(a_segment, b_segment);
        
        // Apply polynomial reduction if needed
        if (gf_multiplier.multiplicand[8]) begin
            temp_result = temp_result ^ irreducible_poly;
        end
    end
    result = temp_result;
endmodule