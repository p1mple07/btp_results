module pseudoRandGenerator_ca (
    input  logic       clock,
    input  logic       reset,
    input  logic [15:0] CA_seed,
    output logic [15:0] CA_out
);

    logic q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16;

    always @(posedge clock) begin
        if (reset)
            state <= {CA_seed[15:1], CA_seed[0]}; // initialize
        else
            state <= {q15, q16, q14, q13, q12, q11, q10, q9, q8, q7, q6, q5, q4, q3, q2, q1};
    end

    assign CA_out = {q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15, q16};

endmodule
