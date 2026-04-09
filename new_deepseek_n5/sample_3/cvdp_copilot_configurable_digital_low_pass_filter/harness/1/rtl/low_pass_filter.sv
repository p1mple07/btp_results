module low_pass_filter (
    input clock,
    input reset,
    input [DATA_WIDTH * NUM_TAPS] data_in,
    input [COEFF_WIDTH * NUM_TAPS] coeffs,
    output [NBW_MULT + $clog2(NUM_TAPS)] data_out,
    output valid_out
);

    // Internal signals
    reg [DATA_WIDTH] data[NUM_TAPS];
    reg [COEFF_WIDTH] coeffs[NUM_TAPS];
    reg [NBW_MULT] mult[NUM_TAPS];
    reg [NBW_MULT + $clog2(NUM_TAPS)] sum;
    reg valid;

    // Reverse coefficients
    function [COEFF_WIDTH] reversed_coeffs = coeffs[NUM_TAPS-1:0];

    // Element-wise multiplication
    for (i = 0; i < NUM_TAPS; i++) begin
        mult[i] = data[i] * reversed_coeffs[i];
    end

    // Summation
    sum = mult[0];
    for (i = 1; i < NUM_TAPS; i++) begin
        sum = sum + mult[i];
    end

    // Valid signal propagation
    valid = valid_in;

    // Output data
    data_out = sum;
    valid_out = valid;

endmodule