module gf_mac #(parameter WIDTH = 8) (
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    output [7:0] result
);
    reg [7:0] temp_result;
    integer i;

    always @(*) begin
        temp_result = 8'b0;
        for (i = 0; i < WIDTH/8; i = i + 1) begin
            gf_multiplier gf_mult_inst (.A(a[(i*8)+7:0]),
                                        .B(b[(i*8)+7:0]),
                                        .result(temp_result));
            if (temp_result[8]) begin
                temp_result = temp_result ^ {8'b100011011}; // Polynomial reduction
            end
            temp_result = temp_result ^ (a & (1 << (i*8))); // XOR with segment of a
            temp_result = temp_result ^ (b & (1 << (i*8))); // XOR with segment of b
        end
        result = temp_result;
    end
endmodule
