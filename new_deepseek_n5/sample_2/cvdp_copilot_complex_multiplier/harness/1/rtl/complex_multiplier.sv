module complex_multiplier (
    input clock,
    input arst_n,
    input [15:0] a_real,
    input [15:0] a_imag,
    input [15:0] b_real,
    input [15:0] b_imag,
    output [31:0] result_real,
    output [31:0] result_imag
);

    // Intermediate results
    reg signed [31:0] real_part;
    reg signed [31:0] imag_part;

    // Compute real part: (a_real * b_real) - (a_imag * b_imag)
    real_part = a_real * b_real;
    real_part -= a_imag * b_imag;

    // Compute imaginary part: (a_real * b_imag) + (a_imag * b_real)
    imag_part = a_real * b_imag;
    imag_part += a_imag * b_real;

    // Assign results with one cycle latency
    result_real = real_part;
    result_imag = imag_part;

    // Negative edge-triggered flip-flop for active low reset
    always_negedge arst_n
        result_real <= real_part;
        result_imag <= imag_part;

endmodule