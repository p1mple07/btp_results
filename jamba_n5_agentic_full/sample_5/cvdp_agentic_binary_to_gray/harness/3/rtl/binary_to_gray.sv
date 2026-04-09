module binary_to_gray (
    input  [WIDTH-1:0]  binary_in,
    output [WIDTH-1:0]  gray_out
);

    parameter WIDTH = 6;

    always_comb begin
        gray_out = binary_in[WIDTH-1];
        for (integer i = 0; i < WIDTH-2; i++) begin
            gray_out = binary_in[i] ^ binary_in[i+1];
        end
    end

endmodule
