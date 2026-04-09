module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    // Local parameters
    localparam logic [17:0] TWO  = 18'b000000010_000000000;  // "2.0" in Q9.9
    localparam logic [17:0] ZERO = 18'b000000000_000000000;  // "0.0" in Q9.9

    // Local signals
    logic [17:0] D_0, N_0, D, N;
    logic [17:0] F, F1, F2, F3, F4, F5, F6, F7, F8, F9;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    // Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Pre-registers for dividend/divisor
    reg18 reg_dividend_pre(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(dividend),
        .data_out(N_0)
    );

    reg18 reg_divisor_pre(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(divisor),
        .data_out(D_0)
    );

    // Pipeline control for "start"
    dff1 ff0(
        .clk   (clk),
        .reset (~rst_n),
        .d     (start),
        .q     (st1)
    );

    // Prescaling: only for magnitude < 1
    logic [17:0] prescaled_divisor, prescaled_dividend;
    pre_scaler prescaler_inst(
        .a(D_0),
        .c(N_0),
        .b(prescaled_divisor),
        .d(prescaled_dividend)
    );

    // Stage 1: Compute F = (2 - D), multiply, register
    always_comb begin
        F = TWO - D;
        D = D_0;
        N = N_0;
    end

    assign D1 = F * D;
    assign N1 = F * N;

    reg18 reg_divisor_stage1(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(prescaled_divisor),
        .data_out(D)
    );

    reg18 reg_dividend_stage1(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(prescaled_dividend),
        .data_out(N)
    );

    dff1 ff1(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st1),
        .q     (st2)
    );

    // Stage 2: F1 = 2 - D2, multiply, register
    always_comb begin
        F1 = TWO - D;
        D = D;
        N = N;
    end

    assign D3 = F1 * D;
    assign N3 = F1 * N;

    reg18 reg_divisor_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),     // Keep 18 bits
        .data_out(D2)
    );

    reg18 reg_dividend_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N2)
    );

    dff1 ff2(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st2),
        .q     (st3)
    );

    // Stage 3: F2 = 2 - D4, multiply, register
    always_comb begin
        F2 = TWO - D;
        D = D2;
        N = N2;
    end

    assign D4 = F2 * D;
    assign N4 = F2 * N;

    reg18 reg_divisor_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D3)
    );

    reg18 reg_dividend_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N3)
    );

    dff1 ff3(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st3),
        .q     (st4)
    );

    // Stage 4: F3 = 2 - D6, multiply, register
    always_comb begin
        F3 = TWO - D;
        D = D3;
        N = N3;
    end

    assign D6 = F3 * D;
    assign N6 = F3 * N;

    reg18 reg_divisor_stage4(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D4)
    );

    reg18 reg_dividend_stage4(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N4)
    );

    dff1 ff4(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st4),
        .q     (st5)
    );

    // Stage 5: F4 = 2 - D8, multiply, register
    always_comb begin
        F4 = TWO - D;
        D = D4;
        N = N4;
    end

    assign D8 = F4 * D;
    assign N8 = F4 * N;

    reg18 reg_divisor_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D5)
    );

    reg18 reg_dividend_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N5)
    );

    dff1 ff6(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st5),
        .q     (st6)
    );

    // Stage 6: F5 = 2 - D10, multiply, register
    always_comb begin
        F5 = TWO - D;
        D = D5;
        N = N5;
    end

    assign D10 = F5 * D;
    assign N10 = F5 * N;

    reg18 reg_divisor_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D6)
    );

    reg18 reg_dividend_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N6)
    );

    dff1 ff8(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st6),
        .q     (st7)
    );

    // Stage 7: F6 = 2 - D12, multiply, register
    always_comb begin
        F6 = TWO - D;
        D = D6;
        N = N6;
    end

    assign D12 = F6 * D;
    assign N12 = F6 * N;

    reg18 reg_divisor_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D7)
    );

    reg18 reg_dividend_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N7)
    );

    dff1 ff9(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st7),
        .q     (st8)
    );

    // Stage 8: F7 = 2 - D14, multiply, register
    always_comb begin
        F7 = TWO - D;
        D = D7;
        N = N7;
    end

    assign D14 = F7 * D;
    assign N14 = F7 * N;

    reg18 reg_divisor_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D8)
    );

    reg18 reg_dividend_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N8)
    );

    dff1 ff10(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st8),
        .q     (st9)
    );

    // Stage 9: F8 = 2 - D16, multiply, register
    always_comb begin
        F8 = TWO - D;
        D = D8;
        N = N8;
    end

    assign D16 = F8 * D;
    assign N16 = F8 * N;

    reg18 reg_divisor_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D9)
    );

    reg18 reg_dividend_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N9)
    );

    dff1 ff11(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st9),
        .q     (st10)
    );

    // Stage 10: F9 = 2 - D18, multiply, register
    always_comb begin
        F9 = TWO - D;
        D = D9;
        N = N9;
    end

    assign D18 = F9 * D;
    assign N18 = F9 * N;

    reg18 reg_divisor_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D10)
    );

    reg18 reg_dividend_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N10)
    );

    dff1 ff12(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st10),
        .q     (st11)
    );

    // Final output register
    reg18 reg_quotient_out(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N10),
        .data_out(dv_out)
    );

    // Final pipeline control
    dff1 ff14(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st11),
        .q     (valid)
    );

endmodule
