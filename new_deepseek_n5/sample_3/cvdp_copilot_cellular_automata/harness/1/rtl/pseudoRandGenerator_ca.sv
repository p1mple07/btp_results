module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // Always active process to load initial state
    always @* begin
        if (reset) {
            q1 = CA_seed[0];
            q2 = CA_seed[1];
            q3 = CA_seed[2];
            q4 = CA_seed[3];
            q5 = CA_seed[4];
            q6 = CA_seed[5];
            q7 = CA_seed[6];
            q8 = CA_seed[7];
            q9 = CA_seed[8];
            q10 = CA_seed[9];
            q11 = CA_seed[10];
            q12 = CA_seed[11];
            q13 = CA_seed[12];
            q14 = CA_seed[13];
            q15 = CA_seed[14];
            q16 = CA_seed[15];
        }
    end

    // Always block to compute next state
    always @+ begin
        logic next_state[16];
        next_state[0] = q1 ^ q15; // Rule 90
        next_state[1] = q2 ^ q1; // Rule 90
        next_state[2] = q3 ^ q1 ^ q2; // Rule 150
        next_state[3] = q4 ^ q2 ^ q3; // Rule 90
        next_state[4] = q5 ^ q3 ^ q4; // Rule 150
        next_state[5] = q6 ^ q4 ^ q5; // Rule 90
        next_state[6] = q7 ^ q5 ^ q6; // Rule 150
        next_state[7] = q8 ^ q6 ^ q7; // Rule 90
        next_state[8] = q9 ^ q7 ^ q8; // Rule 150
        next_state[9] = q10 ^ q8 ^ q9; // Rule 90
        next_state[10] = q11 ^ q9 ^ q10; // Rule 150
        next_state[11] = q12 ^ q10 ^ q11; // Rule 90
        next_state[12] = q13 ^ q11 ^ q12; // Rule 150
        next_state[13] = q14 ^ q12 ^ q13; // Rule 90
        next_state[14] = q15 ^ q13 ^ q14; // Rule 150
        next_state[15] = q1 ^ q14 ^ q12; // Rule 90

        q1 = next_state[0];
        q2 = next_state[1];
        q3 = next_state[2];
        q4 = next_state[3];
        q5 = next_state[4];
        q6 = next_state[5];
        q7 = next_state[6];
        q8 = next_state[7];
        q9 = next_state[8];
        q10 = next_state[9];
        q11 = next_state[10];
        q12 = next_state[11];
        q13 = next_state[12];
        q14 = next_state[13];
        q15 = next_state[14];
        q16 = next_state[15];
    end

    // Output the CA_out
    CA_out = q16;