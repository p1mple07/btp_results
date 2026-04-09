module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16;

    // Cellular Automata logic for Rule 90 and Rule 150
    always @(posedge clock) begin
        if (reset) begin
            q1 <= CA_seed[0];
            q2 <= CA_seed[1];
            q3 <= CA_seed[2];
            q4 <= CA_seed[3];
            q5 <= CA_seed[4];
            q6 <= CA_seed[5];
            q7 <= CA_seed[6];
            q8 <= CA_seed[7];
            q9 <= CA_seed[8];
            q10 <= CA_seed[9];
            q11 <= CA_seed[10];
            q12 <= CA_seed[11];
            q13 <= CA_seed[12];
            q14 <= CA_seed[13];
            q15 <= CA_seed[14];
            q16 <= CA_seed[15];
        end else begin
            q1 <= q9 ^ q10 ^ q11; // Rule 150
            q2 <= q1 ^ q10;      // Rule 90
            q3 <= q1 ^ q11;
            q4 <= q2 ^ q10;
            q5 <= q2 ^ q11;
            q6 <= q3 ^ q10;
            q7 <= q3 ^ q11;
            q8 <= q4 ^ q10;
            q9 <= q4 ^ q11;
            q10 <= q5 ^ q10;
            q11 <= q5 ^ q11;
            q12 <= q6 ^ q10;
            q13 <= q6 ^ q11;
            q14 <= q7 ^ q10;
            q15 <= q7 ^ q11;
            q16 <= q8 ^ q10;
        end

        CA_out <= {q16, q15, q14, q13, q12, q11, q10, q9}; // Shift the output
    end

endmodule
