module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    logic next_state[16];

    // Compute next states using Rule 90 and Rule 150
    q1_next = q16 ^ q2;
    q2_next = q1 ^ q3;
    q3_next = q3 ^ q2 ^ q4;
    q4_next = q3 ^ q5;
    q5_next = q5 ^ q4 ^ q6;
    q6_next = q5 ^ q7;
    q7_next = q7 ^ q6 ^ q8;
    q8_next = q7 ^ q9;
    q9_next = q9 ^ q8 ^ q10;
    q10_next = q9 ^ q11;
    q11_next = q11 ^ q10 ^ q12;
    q12_next = q11 ^ q13;
    q13_next = q13 ^ q12 ^ q14;
    q14_next = q13 ^ q15;
    q15_next = q15 ^ q14 ^ q16;
    q16_next = q15 ^ q1;

    // Store next states in array
    next_state[0] = q1_next;
    next_state[1] = q2_next;
    next_state[2] = q3_next;
    next_state[3] = q4_next;
    next_state[4] = q5_next;
    next_state[5] = q6_next;
    next_state[6] = q7_next;
    next_state[7] = q8_next;
    next_state[8] = q9_next;
    next_state[9] = q10_next;
    next_state[10] = q11_next;
    next_state[11] = q12_next;
    next_state[12] = q13_next;
    next_state[13] = q14_next;
    next_state[14] = q15_next;
    next_state[15] = q16_next;

    // Update q variables with next states
    next q1 = next_state[0];
    next q2 = next_state[1];
    next q3 = next_state[2];
    next q4 = next_state[3];
    next q5 = next_state[4];
    next q6 = next_state[5];
    next q7 = next_state[6];
    next q8 = next_state[7];
    next q9 = next_state[8];
    next q10 = next_state[9];
    next q11 = next_state[10];
    next q12 = next_state[11];
    next q13 = next_state[12];
    next q14 = next_state[13];
    next q15 = next_state[14];
    next q16 = next_state[15];

    // Output the new state
    CA_out = q1;