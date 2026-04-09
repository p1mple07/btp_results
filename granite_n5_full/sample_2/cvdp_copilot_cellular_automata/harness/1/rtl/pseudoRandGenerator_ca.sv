module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    always @(posedge clock) begin
        if (reset) begin
            // Initialize the CA-based shift register with the provided seed value
            q1 <= CA_seed[15];
            q2 <= CA_seed[14];
            q3 <= CA_seed[13];
            q4 <= CA_seed[12];
            q5 <= CA_seed[11];
            q6 <= CA_seed[10];
            q7 <= CA_seed[9];
            q8 <= CA_seed[8];

            q9 <= CA_seed[7];
            q10 <= CA_seed[6];
            q11 <= CA_seed[5];
            q12 <= CA_seed[4];
            q13 <= CA_seed[3];
            q14 <= CA_seed[2];
            q15 <= CA_seed[1];
            q16 <= CA_seed[0];
        end else begin
            // Calculate the new state of each bit in the CA-based shift register based on rules 90 and 150
            q1 <= q2;
            q2 <= q3;
            q3 <= q4;
            q4 <= q5;
            q5 <= q6;
            q6 <= q7;
            q7 <= q8;
            q8 <= ~q9 & q10 | q9 & ~q10;

            q9 <= q10;
            q10 <= q11;
            q11 <= q12;
            q12 <= q13;
            q13 <= q14;
            q14 <= q15;
            q15 <= q16;
            q16 <= ~q1 & q2 | q1 & ~q2;
        end
    end

    assign CA_out = {q16, q15, q14, q13, q12, q11, q10, q9};

endmodule