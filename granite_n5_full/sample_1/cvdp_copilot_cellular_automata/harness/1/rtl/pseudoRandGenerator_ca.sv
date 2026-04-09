module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // Insert code here for the calculation of Rule 90 and Rule 150 to each bit of 
    // output and bit movement in the CA-based shift register with configuration 
    // R90-R90-R150-R90-R150-R90-R150-R90-R150-R90-R150-R90-R150-R90-R150-R90.
    
    // Here's how we can use the above calculation to generate the pseudorandom output:
    assign q1 = CA_seed[15];
    assign q2 = CA_seed[14];
    assign q3 = CA_seed[13];
    assign q4 = CA_seed[12];
    assign q5 = CA_seed[11];
    assign q6 = CA_seed[10];
    assign q7 = CA_seed[9];
    assign q8 = CA_seed[8];
    
    assign q9 = CA_seed[7];
    assign q10 = CA_seed[6];
    assign q11 = CA_seed[5];
    assign q12 = CA_seed[4];
    assign q13 = CA_seed[3];
    assign q14 = CA_seed[2];
    assign q15 = CA_seed[1];
    assign q16 = CA_seed[0];
    
    assign CA_out[15] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[14] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[13] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[12] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[11] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[10] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[9] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[8] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[7] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[6] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[5] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[4] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[3] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[2] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;
    assign CA_out[1] = q1 ^ q2 ^ q3 ^ q4 ^ q5 ^ q6 ^ q7 ^ q8;
    assign CA_out[0] = q9 ^ q10 ^ q11 ^ q12 ^ q13 ^ q14 ^ q15 ^ q16;

endmodule