module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    // Internal state bits. We assume a circular shift register where
    // q1 is the MSB and q16 is the LSB.
    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // The CA configuration is:
    // Bit  1: Rule 90  -> new_q1 = q16 XOR q2
    // Bit  2: Rule 90  -> new_q2 = q1 XOR q3
    // Bit  3: Rule 150 -> new_q3 = q2 XOR q3 XOR q4
    // Bit  4: Rule 90  -> new_q4 = q3 XOR q5
    // Bit  5: Rule 150 -> new_q5 = q4 XOR q5 XOR q6
    // Bit  6: Rule 90  -> new_q6 = q5 XOR q7
    // Bit  7: Rule 150 -> new_q7 = q6 XOR q7 XOR q8
    // Bit  8: Rule 90  -> new_q8 = q7 XOR q9
    // Bit  9: Rule 150 -> new_q9 = q8 XOR q9 XOR q10
    // Bit 10: Rule 90  -> new_q10 = q9 XOR q11
    // Bit 11: Rule 150 -> new_q11 = q10 XOR q11 XOR q12
    // Bit 12: Rule 90  -> new_q12 = q11 XOR q13
    // Bit 13: Rule 150 -> new_q13 = q12 XOR q13 XOR q14
    // Bit 14: Rule 90  -> new_q14 = q13 XOR q15
    // Bit 15: Rule 150 -> new_q15 = q14 XOR q15 XOR q16
    // Bit 16: Rule 90  -> new_q16 = q15 XOR q1

    always_ff @(posedge clock) begin
        if (reset) begin
            // Synchronous reset: initialize internal state with CA_seed.
            // Note: CA_seed[15] is the MSB and CA_seed[0] is the LSB.
            q1  <= CA_seed[15];
            q2  <= CA_seed[14];
            q3  <= CA_seed[13];
            q4  <= CA_seed[12];
            q5  <= CA_seed[11];
            q6  <= CA_seed[10];
            q7  <= CA_seed[9];
            q8  <= CA_seed[8];
            q9  <= CA_seed[7];
            q10 <= CA_seed[6];
            q11 <= CA_seed[5];
            q12 <= CA_seed[4];
            q13 <= CA_seed[3];
            q14 <= CA_seed[2];
            q15 <= CA_seed[1];
            q16 <= CA_seed[0];
        end
        else begin
            // Update internal state based on the combination of Rules 90 and 150.
            q1  <= q16 ^ q2;           // Rule 90 for bit 1
            q2  <= q1  ^ q3;           // Rule 90 for bit 2
            q3  <= q2  ^ q3 ^ q4;      // Rule 150 for bit 3
            q4  <= q3  ^ q5;           // Rule 90 for bit 4
            q5  <= q4  ^ q5 ^ q6;      // Rule 150 for bit 5
            q6  <= q5  ^ q7;           // Rule 90 for bit 6
            q7  <= q6  ^ q7 ^ q8;      // Rule 150 for bit 7
            q8  <= q7  ^ q9;           // Rule 90 for bit 8
            q9  <= q8  ^ q9 ^ q10;     // Rule 150 for bit 9
            q10 <= q9  ^ q11;          // Rule 90 for bit 10
            q11 <= q10 ^ q11 ^ q12;    // Rule 150 for bit 11
            q12 <= q11 ^ q13;          // Rule 90 for bit 12
            q13 <= q12 ^ q13 ^ q14;    // Rule 150 for bit 13
            q14 <= q13 ^ q15;          // Rule 90 for bit 14
            q15 <= q14 ^ q15 ^ q16;    // Rule 150 for bit 15
            q16 <= q15 ^ q1;           // Rule 90 for bit 16
        end

        // Update the output with the new state.
        // The concatenation order is {q1, q2, ..., q16} corresponding to bits [15:0].
        CA_out <= {q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16};
    end

endmodule