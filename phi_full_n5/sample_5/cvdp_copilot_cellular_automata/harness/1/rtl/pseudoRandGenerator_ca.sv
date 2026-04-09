module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // Rule 90 and Rule 150 implementation
    always @(posedge clock) begin
        if (reset) begin
            CA_out <= CA_seed;
            q1 <= CA_seed[15];
            q2 <= CA_seed[14] ^ q1;
            q3 <= CA_seed[13] ^ q2;
            q4 <= CA_seed[12] ^ q3;
            q5 <= CA_seed[11] ^ q4;
            q6 <= CA_seed[10] ^ q5;
            q7 <= CA_seed[9] ^ q6;
            q8 <= CA_seed[8] ^ q7;

            q9 <= CA_seed[7] ^ q8;
            q10 <= CA_seed[6] ^ q9;
            q11 <= CA_seed[5] ^ q10;
            q12 <= CA_seed[4] ^ q11;
            q13 <= CA_seed[3] ^ q12;
            q14 <= CA_seed[2] ^ q13;
            q15 <= CA_seed[1] ^ q14;
            q16 <= CA_seed[0] ^ q15;

            CA_out <= q16 ^ q15 ^ q14 ^ q13 ^ q12 ^ q11 ^ q10 ^ q9 ^ q8 ^ q7 ^ q6 ^ q5 ^ q4 ^ q3 ^ q2 ^ q1;
        end else begin
            CA_out <= CA_out;
        end
    end

endmodule
