module gf_mac (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [7:0] result
);
    parameter WIDTH = 8; // Configurable width in bits (must be multiple of 8)
    reg [7:0] temp_result = 0;
    reg [7:0] multiplicand;
    reg [8:0] irreducible_poly = 9'b100011011;
    integer i;
    
    // Split input into 8-bit segments
    reg [8:0] a_segments[WIDTH/8];
    reg [8:0] b_segments[WIDTH/8];
    
    // Extract segments from input
    for (i = 0; i < WIDTH/8; i = i + 1) begin
        a_segments[i] = a[8*i:8*i+7];
        b_segments[i] = b[8*i:8*i+7];
    end
    
    // Perform MAC operation on each segment
    for (i = 0; i < WIDTH/8; i = i + 1) begin
        // Multiply current segments
        temp_result = gf_multiplier({1'b0, a_segments[i]}, b_segments[i]);
        
        // Accumulate result using XOR
        result = temp_result ^ result;
    end
endmodule