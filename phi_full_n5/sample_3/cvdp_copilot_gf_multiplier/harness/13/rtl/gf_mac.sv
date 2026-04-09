module gf_mac #(parameter WIDTH = 8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output reg [7:0] result
);
    reg [7:0] temp_result;
    integer i;

    always @(*) begin
        result = 8'b0;
        for (i = 0; i < WIDTH/8; i = i + 1) begin
            // Extract 8-bit segments from a and b
            reg [7:0] a_segment = {a[(i*8)+:8], 8'h0};
            reg [7:0] b_segment = {b[(i*8)+:8], 8'h0};
            
            // Apply gf_multiplier to each segment
            reg segment_result;
            gf_multiplier #(.WIDTH(8)) multiplier_instance (
                .A(a_segment),
                .B(b_segment),
                .result(segment_result)
            );
            
            // Perform polynomial reduction if necessary
            if (segment_result[8]) begin
                segment_result = segment_result ^ 9'b100011011;
            end
            
            // XOR the result with the cumulative result
            temp_result = temp_result ^ segment_result;
        end
        
        // The final result is the accumulated XOR of all segment results
        result = temp_result;
    end
endmodule
