module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // State register for Rule 90
    logic [15:0] rule90_state [15:0];
    // State register for Rule 150
    logic [15:0] rule150_state [15:0];

    // Initialization
    initial begin
        if (reset) begin
            CA_out <= CA_seed;
            rule90_state <= CA_seed;
            rule150_state <= CA_seed;
        end
    end

    // Evolution of Cellular Automata
    always @(posedge clock) begin
        if (reset) begin
            CA_out <= CA_seed;
        end else begin
            // Rule 90
            rule90_state <= rule90_state[15:0] ^ rule90_state[14:1];
            // Rule 150
            rule150_state <= rule150_state[15:0] ^ rule150_state[14:1] ^ CA_seed[15:1];

            // Combine outputs of Rule 90 and Rule 150
            CA_out <= rule90_state[15:0] ^ rule150_state[15:0];
        end
    end

endmodule
