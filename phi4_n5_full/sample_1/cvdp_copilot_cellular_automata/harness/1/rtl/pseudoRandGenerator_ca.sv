module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    // Internal state bits (assumed to be arranged from leftmost to rightmost)
    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // On every rising edge of clock, update the CA state.
    // When reset is high, load the seed into both CA_out and the internal state.
    // Otherwise, update each bit using the combination of Rule 90 and Rule 150.
    // The rule configuration (from leftmost cell to rightmost cell) is:
    // R90, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90, R150, R90.
    // In a circular CA, the neighbors of cell 1 are cell 16 (left) and cell 2 (right),
    // and similarly for cell 16 (neighbors are cell 15 and cell 1).
    // Rule 90: new state = left XOR right.
    // Rule 150: new state = left XOR current XOR right.
    always_ff @(posedge clock) begin
        if (reset) begin
            // Synchronous reset: initialize CA_out and internal state with CA_seed.
            // Assuming CA_seed[15] is the leftmost bit and CA_seed[0] is the rightmost.
            CA_out <= CA_seed;
            q1   <= CA_seed[15];
            q2   <= CA_seed[14];
            q3   <= CA_seed[13];
            q4   <= CA_seed[12];
            q5   <= CA_seed[11];
            q6   <= CA_seed[10];
            q7   <= CA_seed[9];
            q8   <= CA_seed[8];
            q9   <= CA_seed[7];
            q10  <= CA_seed[6];
            q11  <= CA_seed[5];
            q12  <= CA_seed[4];
            q13  <= CA_seed[3];
            q14  <= CA_seed[2];
            q15  <= CA_seed[1];
            q16  <= CA_seed[0];
        end
        else begin
            // Update each cell concurrently using the previous state (non-blocking assignments ensure old values are used)
            // Cell 1 (R90): new state = q16 XOR q2
            q1   <= q16 ^ q2;
            // Cell 2 (R90): new state = q1 XOR q3
            q2   <= q1 ^ q3;
            // Cell 3 (R150): new state = q2 XOR q3 XOR q4
            q3   <= q2 ^ q3 ^ q4;
            // Cell 4 (R90): new state = q3 XOR q5
            q4   <= q3 ^ q5;
            // Cell 5 (R150): new state = q4 XOR q5 XOR q6
            q5   <= q4 ^ q5 ^ q6;
            // Cell 6 (R90): new state = q5 XOR q7
            q6   <= q5 ^ q7;
            // Cell 7 (R150): new state = q6 XOR q7 XOR q8
            q7   <= q6 ^ q7 ^ q8;
            // Cell 8 (R90): new state = q7 XOR q9
            q8   <= q7 ^ q9;
            // Cell 9 (R150): new state = q8 XOR q9 XOR q10
            q9   <= q8 ^ q9 ^ q10;
            // Cell 10 (R90): new state = q9 XOR q11
            q10  <= q9 ^ q11;
            // Cell 11 (R150): new state = q10 XOR q11 XOR q12
            q11  <= q10 ^ q11 ^ q12;
            // Cell 12 (R90): new state = q11 XOR q13
            q12  <= q11 ^ q13;
            // Cell 13 (R150): new state = q12 XOR q13 XOR q14
            q13  <= q12 ^ q13 ^ q14;
            // Cell 14 (R90): new state = q13 XOR q15
            q14  <= q13 ^ q15;
            // Cell 15 (R150): new state = q14 XOR q15 XOR q16
            q15  <= q14 ^ q15 ^ q16;
            // Cell 16 (R90): new state = q15 XOR q1 (circular neighbor)
            q16  <= q15 ^ q1;

            // Update the output with the new state.
            // Here, q1 is the most significant bit and q16 is the least significant bit.
            CA_out <= {q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16};
        end
    end

endmodule