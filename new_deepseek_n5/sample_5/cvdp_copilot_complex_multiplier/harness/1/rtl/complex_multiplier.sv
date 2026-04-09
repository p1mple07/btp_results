module complex_multiplier (
    input clock,
    input arst_n,
    input a_real,
    input a_imag,
    input b_real,
    input b_imag,
    output result_real,
    output result_imag
);

    // 32-bit signed registers for result
    reg [31:0] result_real, result_imag;

    // Intermediate 32-bit results
    reg [31:0] temp_ac, temp_bd, temp_ad, temp_bc;

    // Compute real part: (a_real * b_real) - (a_imag * b_imag)
    temp_ac = a_real * b_real;
    temp_bd = a_imag * b_imag;
    result_real = temp_ac - temp_bd;

    // Compute imaginary part: (a_real * b_imag) + (a_imag * b_real)
    temp_ad = a_real * b_imag;
    temp_bc = a_imag * b_real;
    result_imag = temp_ad + temp_bc;

    // Output the results
    result_real = result_real;
    result_imag = result_imag;
endmodule