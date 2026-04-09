// Port Declaration
input  clk;
input  arst_n;
input  a_real;
input  a_imag;
input  b_real;
input  b_imag;
output result_real;
output result_imag;

// Logic Implementation
reg result_real, result_imag;

// Compute real part: (a_real * b_real) - (a_imag * b_imag)
// Compute imaginary part: (a_real * b_imag) + (a_imag * b_real)
always @* begin
    result_real = a_real * b_real - a_imag * b_imag;
    result_imag = a_real * b_imag + a_imag * b_real;
    $tick; // One cycle delay
end