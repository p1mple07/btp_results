// ------------------------------------------------------------------
// Core division engine – now uses only two reg18 instances
// ------------------------------------------------------------------
module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    // Prescale divisor to 1.0 (integer bits 0)
    reg18 reg_block1 = new();
    reg18 reg_block2 = new();

    // Main iterative stage
    always_comb begin
        // Shift and combine to converge to 1.0
        reg [2:0] F = {TWO, ZERO, ONE};
        reg [47:0] D1, N1;
        reg [47:0] F1, N11;

        // … (rest of the iterative logic unchanged) …
    end

endmodule
