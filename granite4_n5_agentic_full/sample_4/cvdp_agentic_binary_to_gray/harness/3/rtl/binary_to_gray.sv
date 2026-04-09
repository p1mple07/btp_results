module binary_to_gray #(parameter WIDTH = 8) (
    input  [WIDTH-1:0] binary_in,
    output [WIDTH-1:0] gray_out
);

genvar i;
generate
    if (WIDTH == 1) begin
        assign gray_out = binary_in;
    end else begin
        always_comb begin
            gray_out[0] = binary_in[0];
            for (i=1; i<WIDTH; i++) begin
                gray_out[i] = binary_in[i] ^ binary_in[i-1];
            end
        end
    end
endgenerate

endmodule