module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16;

    // Calculate next state for each bit using Rules 90 and 150
    q1 = (CA_seed[15] ^ CA_seed[1]);
    q2 = (CA_seed[0] ^ CA_seed[2]);
    q3 = (CA_seed[2] ^ CA_seed[1] ^ CA_seed[3]);
    q4 = (CA_seed[2] ^ CA_seed[4]);
    q5 = (CA_seed[4] ^ CA_seed[3] ^ CA_seed[5]);
    q6 = (CA_seed[4] ^ CA_seed[6]);
    q7 = (CA_seed[6] ^ CA_seed[5] ^ CA_seed[7]);
    q8 = (CA_seed[6] ^ CA_seed[8]);
    q9 = (CA_seed[8] ^ CA_seed[7] ^ CA_seed[9]);
    q10 = (CA_seed[8] ^ CA_seed[10]);
    q11 = (CA_seed[10] ^ CA_seed[9] ^ CA_seed[11]);
    q12 = (CA_seed[10] ^ CA_seed[12]);
    q13 = (CA_seed[12] ^ CA_seed[11] ^ CA_seed[13]);
    q14 = (CA_seed[12] ^ CA_seed[14]);
    q15 = (CA_seed[14] ^ CA_seed[13] ^ CA_seed[15]);
    q16 = (CA_seed[14] ^ CA_seed[0]);

    // Shift the computed bits into the output
    CA_out = (q1 << 15) | (q2 << 14) | (q3 << 13) | (q4 << 12) |
             (q5 << 11) | (q6 << 10) | (q7 << 9) | (q8 << 8) |
             (q9 << 7) | (q10 << 6) | (q11 << 5) | (q12 << 4) |
             (q13 << 3) | (q14 << 2) | (q15 << 1) | q16;