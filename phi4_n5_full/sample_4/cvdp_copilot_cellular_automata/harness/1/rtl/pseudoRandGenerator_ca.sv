// File: rtl/pseudoRandGenerator_ca.sv
module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    // Internal state bits for the 16-bit CA register.
    // q1 corresponds to bit0, q2 to bit1, ..., q16 to bit15.
    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // On every clock edge, update the CA state.
    // When reset is high, initialize the state from CA_seed.
    // Otherwise, compute the next state using a combination of Rule 90 and Rule 150.
    // The configuration is:
    //   Bit0:  R90  -> new state = 0 XOR q2 = q2
    //   Bit1:  R90  -> new state = q1 XOR q3
    //   Bit2:  R150 -> new state = q2 XOR (q1 XOR q4) = q2 ^ q1 ^ q4
    //   Bit3:  R90  -> new state = q3 XOR q5
    //   Bit4:  R150 -> new state = q4 XOR (q3 XOR q6) = q4 ^ q3 ^ q6
    //   Bit5:  R90  -> new state = q5 XOR q7
    //   Bit6:  R150 -> new state = q6 XOR (q5 XOR q8) = q6 ^ q5 ^ q8
    //   Bit7:  R90  -> new state = q7 XOR q9
    //   Bit8:  R150 -> new state = q8 XOR (q7 XOR q10) = q8 ^ q7 ^ q10
    //   Bit9:  R90  -> new state = q9 XOR q11
    //   Bit10: R150 -> new state = q10 XOR (q9 XOR q12) = q10 ^ q9 ^ q12
    //   Bit11: R90  -> new state = q11 XOR q13
    //   Bit12: R150 -> new state = q12 XOR (q11 XOR q14) = q12 ^ q11 ^ q14
    //   Bit13: R90  -> new state = q13 XOR q15
    //   Bit14: R150 -> new state = q14 XOR (q13 XOR q16) = q14 ^ q13 ^ q16
    //   Bit15: R90  -> new state = q15 XOR 0 = q15
    //
    // Note: For the leftmost cell (bit0) and rightmost cell (bit15),
    //       the missing neighbor is assumed to be 0.
    always_ff @(posedge clock) begin
        if (reset) begin
            q1  <= CA_seed[0];
            q2  <= CA_seed[1];
            q3  <= CA_seed[2];
            q4  <= CA_seed[3];
            q5  <= CA_seed[4];
            q6  <= CA_seed[5];
            q7  <= CA_seed[6];
            q8  <= CA_seed[7];
            q9  <= CA_seed[8];
            q10 <= CA_seed[9];
            q11 <= CA_seed[10];
            q12 <= CA_seed[11];
            q13 <= CA_seed[12];
            q14 <= CA_seed[13];
            q15 <= CA_seed[14];
            q16 <= CA_seed[15];
        end
        else begin
            // Compute the next state for each bit based on the CA rules.
            logic new_q1, new_q2, new_q3, new_q4, new_q5, new_q6, new_q7, new_q8;
            logic new_q9, new_q10, new_q11, new_q12, new_q13, new_q14, new_q15, new_q16;

            // Bit0 (q1): Rule 90 -> new state = 0 XOR q2 = q2
            new_q1 = q2;
            // Bit1 (q2): Rule 90 -> new state = q1 XOR q3
            new_q2 = q1 ^ q3;
            // Bit2 (q3): Rule 150 -> new state = q2 XOR (q1 XOR q4)
            new_q3 = q2 ^ q1 ^ q4;
            // Bit3 (q4): Rule 90 -> new state = q3 XOR q5
            new_q4 = q3 ^ q5;
            // Bit4 (q5): Rule 150 -> new state = q4 XOR (q3 XOR q6)
            new_q5 = q4 ^ q3 ^ q6;
            // Bit5 (q6): Rule 90 -> new state = q5 XOR q7
            new_q6 = q5 ^ q7;
            // Bit6 (q7): Rule 150 -> new state = q6 XOR (q5 XOR q8)
            new_q7 = q6 ^ q5 ^ q8;
            // Bit7 (q8): Rule 90 -> new state = q7 XOR q9
            new_q8 = q7 ^ q9;
            // Bit8 (q9): Rule 150 -> new state = q8 XOR (q7 XOR q10)
            new_q9 = q8 ^ q7 ^ q10;
            // Bit9 (q10): Rule 90 -> new state = q9 XOR q11
            new_q10 = q9 ^ q11;
            // Bit10 (q11): Rule 150 -> new state = q10 XOR (q9 XOR q12)
            new_q11 = q10 ^ q9 ^ q12;
            // Bit11 (q12): Rule 90 -> new state = q11 XOR q13
            new_q12 = q11 ^ q13;
            // Bit12 (q13): Rule 150 -> new state = q12 XOR (q11 XOR q14)
            new_q13 = q12 ^ q11 ^ q14;
            // Bit13 (q14): Rule 90 -> new state = q13 XOR q15
            new_q14 = q13 ^ q15;
            // Bit14 (q15): Rule 150 -> new state = q14 XOR (q13 XOR q16)
            new_q15 = q14 ^ q13 ^ q16;
            // Bit15 (q16): Rule 90 -> new state = q15 XOR 0 = q15
            new_q16 = q15;

            // Update the state with the newly computed values.
            q1  <= new_q1;
            q2  <= new_q2;
            q3  <= new_q3;
            q4  <= new_q4;
            q5  <= new_q5;
            q6  <= new_q6;
            q7  <= new_q7;
            q8  <= new_q8;
            q9  <= new_q9;
            q10 <= new_q10;
            q11 <= new_q11;
            q12 <= new_q12;
            q13 <= new_q13;
            q14 <= new_q14;
            q15 <= new_q15;
            q16 <= new_q16;
        end
    end

    // Drive the output with the updated CA state.
    assign CA_out = {q1, q2, q3, q4, q5,