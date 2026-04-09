module pseudoRandGenerator_ca (
    input  logic       clock,    // Clock input
    input  logic       reset,    // Active-high synchronous Reset
    input  logic [15:0] CA_seed,  // 16-bit Cellular Automata seed
    output logic [15:0] CA_out    // 16-bit Cellular Automata output
);

    logic q1, q2, q3, q4, q5, q6, q7, q8;
    logic q9, q10, q11, q12, q13, q14, q15, q16;

    // State registers for the 16-bit shift register
    logic [15:0] shift_reg_90 [15:0];
    logic [15:0] shift_reg_150 [15:0];

    // Rule 90 calculation
    always @(posedge clock) begin
        if (!reset) begin
            // Initialize shift registers with the seed
            shift_reg_90 <= CA_seed;
            shift_reg_150 <= CA_seed;
        end else begin
            // Rule 90: q(i) = q(i-1) XOR q(i-2)
            shift_reg_90 <= {shift_reg_90[14:0], q9 ^ q7, q6};
            shift_reg_150 <= {shift_reg_150[14:0], q10 ^ q9 ^ q8, q11 ^ q10};
        end
    end

    // Rule 150 calculation
    always @(posedge clock) begin
        if (!reset) begin
            // Initialize shift registers with the seed
            shift_reg_90 <= CA_seed;
            shift_reg_150 <= CA_seed;
        end else begin
            // Rule 150: q(i) = q(i) XOR q(i-1) XOR q(i-2)
            shift_reg_90 <= {shift_reg_90[14:0], q9 ^ q8, q7};
            shift_reg_150 <= {shift_reg_150[14:0], q10 ^ q9 ^ q8, q11 ^ q10};
        end
    end

    // Output logic
    assign CA_out = shift_reg_90[15] ^ shift_reg_150[15]; // XOR of both rules to generate the output

endmodule
