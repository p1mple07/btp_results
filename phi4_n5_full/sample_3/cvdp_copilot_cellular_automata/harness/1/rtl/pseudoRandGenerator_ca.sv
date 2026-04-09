module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    // Internal CA state bits (q1 is MSB, q16 is LSB)
    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // On each rising edge of clock, update the CA state.
    // The CA is implemented as a circular shift register with 16 cells.
    // Each cell is updated using one of two rules:
    //   • Rule 90: new state = left_neighbor XOR right_neighbor
    //   • Rule 150: new state = left_neighbor XOR right_neighbor XOR current
    // The configuration (from MSB to LSB) is:
    //   R90, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90.
    // With wrap-around, the left neighbor of q1 is q16 and the right neighbor of q16 is q1.
    always_ff @(posedge clock) begin
        if (reset) begin
            // Synchronous reset: initialize CA_out and internal state from CA_seed.
            // Mapping: q1 = CA_seed[15] (MSB), q16 = CA_seed[0] (LSB)
            CA_out   <= CA_seed;
            q1       <= CA_seed[15];
            q2       <= CA_seed[14];
            q3       <= CA_seed[13];
            q4       <= CA_seed[12];
            q5       <= CA_seed[11];
            q6       <= CA_seed[10];
            q7       <= CA_seed[9];
            q8       <= CA_seed[8];
            q9       <= CA_seed[7];
            q10      <= CA_seed[6];
            q11      <= CA_seed[5];
            q12      <= CA_seed[4];
            q13      <= CA_seed[3];
            q14      <= CA_seed[2];
            q15      <= CA_seed[1];
            q16      <= CA_seed[0];
        end else begin
            // Compute new state for each cell using the designated rule.
            // Note: Each new value is computed from the previous state (old values)
            // because non-blocking assignments ensure concurrent update.
            // q1's left neighbor is q16 and right neighbor is q2.
            q1 <= q16 ^ q2;           // Rule 90: new q1 = q16 XOR q2
            // q2's neighbors: left = q1, right = q3.
            q2 <= q1 ^ q3;           // Rule 90: new q2 = q1 XOR q3
            // q3's neighbors: left = q2, right = q4, plus current q3 for Rule 150.
            q3 <= q2 ^ q4 ^ q3;      // Rule 150: new q3 = q2 XOR q4 XOR q3
            // q4's neighbors: left = q3, right = q5.
            q4 <= q3 ^ q5;           // Rule 90: new q4 = q3 XOR q5
            // q5's neighbors: left = q4, right = q6.
            q5 <= q4 ^ q6 ^ q5;      // Rule 150: new q5 = q4 XOR q6 XOR q5
            // q6's neighbors: left = q5, right = q7.
            q6 <= q5 ^ q7;           // Rule 90: new q6 = q5 XOR q7
            // q7's neighbors: left = q6, right = q8.
            q7 <= q6 ^ q8 ^ q7;      // Rule 150: new q7 = q6 XOR q8 XOR q7
            // q8's neighbors: left = q7, right = q9.
            q8 <= q7 ^ q9;           // Rule 90: new q8 = q7 XOR q9
            // q9's neighbors: left = q8, right = q10.
            q9 <= q8 ^ q10 ^ q9;     // Rule 150: new q9 = q8 XOR q10 XOR q9
            // q10's neighbors: left = q9, right = q11.
            q10 <= q9 ^ q11;         // Rule 90: new q10 = q9 XOR q11
            // q11's neighbors: left = q10, right = q12.
            q11 <= q10 ^ q12 ^ q11;  // Rule 150: new q11 = q10 XOR q12 XOR q11
            // q12's neighbors: left = q11, right = q13.
            q12 <= q11 ^ q13;        // Rule 90: new q12 = q11 XOR q13
            // q13's neighbors: left = q12, right = q14.
            q13 <= q12 ^ q14 ^ q13;  // Rule 150: new q13 = q12 XOR q14 XOR q13
            // q14's neighbors: left = q13, right = q15.
            q14 <= q13 ^ q15;        // Rule 90: new q14 = q13 XOR q15
            // q15's neighbors: left = q14, right = q16.
            q15 <= q14 ^ q16 ^ q15;  // Rule 150: new q15 = q14 XOR q16 XOR q15
            // q16's neighbors: left = q15, right = q1.
            q16 <= q15 ^ q1;         // Rule 90: new q16 = q15 XOR q1

            // Update the output register with the new state.
            CA_out <= {q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16};
        end
    end

endmodule