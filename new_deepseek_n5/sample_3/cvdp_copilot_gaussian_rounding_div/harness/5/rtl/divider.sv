module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    logic [17:0] D_0, N_0;
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    //Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Gold-Schmidt factors
    logic [17:0] TWO = 18'b000000010_000000000,
                  ZERO = 18'b000000000_000000000;

    // Pre-scaling module
    wire [17:0] pre_dividend, pre_divisor;
    pre_scaler(divisor, dividend, pre_divisor, pre_dividend);

    // Pipeline stages
    always logic valid = 1;
    always logic st1 = 1;
    always logic st2 = 1;
    always logic st3 = 1;
    always logic st4 = 1;
    always logic st5 = 1;
    always logic st6 = 1;
    always logic st7 = 1;
    always logic st8 = 1;
    always logic st9 = 1;
    always logic st10 = 1;
    always logic st11 = 1;
    always logic st12 = 1;

    // Iterations
    always logic valid = 1;
    for (int i = 0; i < 10; i++) {
        // Step 1: Generate multiplication factor
        F[i] = 2 - D_prev;

        // Step 2: Multiply dividend and divisor by F[i]
        D_current = D_prev * F[i];
        N_current = N_prev * F[i];

        // Step 3: Update intermediate values
        D_next = D_current;
        N_next = N_current;

        // Step 4: Update factors
        F_next = F[i] * 2 - D_current;
    }

    // After iterations, output the result
    dv_out = N_final;
    valid = 1;

    // Final valid assertion
    valid = 1;

endmodule