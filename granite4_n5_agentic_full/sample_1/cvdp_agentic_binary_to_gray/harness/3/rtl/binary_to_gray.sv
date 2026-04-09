module binary_to_gray #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] binary_in,
    output [WIDTH-1:0] gray_out
);

    always @* begin
        gray_out[0] = binary_in[0];

        for (genvar i = 1; i < WIDTH; i++) begin
            gray_out[i] = binary_in[i] ^ binary_in[i-1];
        end
    end

endmodule