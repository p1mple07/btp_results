
module complex_multiplier (
    input         clk,
    input         arst_n,
    input         a_real[15:0], a_imag[15:0],
    input         b_real[15:0], b_imag[15:0],
    output reg [31:0] result_real,
    output reg [31:0] result_imag
);
