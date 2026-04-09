module binary_to_gray #(parameter WIDTH = 6) (
    input  wire [WIDTH-1:0] binary_in,
    output wire [WIDTH-1:0] gray_out
);

    assign  gray_out[WIDTH-1] = binary_in[WIDTH-1];  // MSB is the same

    generate
        genvar i;
        for (i=WIDTH-2; i>=0; i--) begin : GEN_BITS
            xor #(.WIDTH(1)) xor_gen (
               .a(binary_in[i]),
               .b(binary_in[i+1]),
               .y(gray_out[i])
            );
        end
    endgenerate

endmodule