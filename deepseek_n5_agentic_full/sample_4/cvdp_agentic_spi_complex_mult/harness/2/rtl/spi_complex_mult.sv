module spi_complex_mult(
    input wire [IN_WIDTH-1:0] ar, // Real part of first complex number
    input wire [IN_WIDTH-1:0] ai, // Imaginary part of first complex number
    input wire [IN_WIDTH-1:0] br, // Real part of second complex number
    input wire [IN_WIDTH-1:0] bi, // Imaginary part of second complex number
    output wire [OUT_WIDTH-1:0] c_real, // Result real part
    output wire [OUT_WIDTH-1:0] c_imag  // Result imaginary part
);

    // Internal buffer to store intermediate results
    reg [OUT_WIDTH-1:0] product_real, product_imag;

    // Multiply real parts
    multiplier #(.clk(spi_sck)) mult_r (
        .ain1(ar),
        .ain2(br),
        .obuf(product_real)
    );

    // Multiply imaginary parts
    multiplier #(.clk(spi_sck)) mult_i (
        .ain1(ai),
        .ain2(bi),
        .obuf(product_imag)
    );

    // Multiply cross terms
    adder #(.clk(spi_sck)) add_r (
        .ain1(product_real),
        .ain2(product_imag),
        .obuf(c_real)
    );

    adder #(.clk(spi_sck)) add_i (
        .ain1(product_real),
        .ain2(product_imag),
        .obuf(c_imag)
    );

endmodule