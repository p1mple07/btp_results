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
    logic [17:0] D_0, N_0, D, N, F, F1, F2, F3, F4, F5, F6, F7, F8, F9, D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;
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
    logic prescaled_divisor, prescaled_dividend;
    pre_scaler prescaler_inst(
        .a(D_0),
        .c(N_0),
        .b(prescaled_divisor),
        .d(prescaled_dividend)
    );

    // Register the prescaled divisor & dividend
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

    // Stage 1: Compute F = (2 - D), multiply, register
    always_comb begin
        F = TWO - D;
    end

    assign D1 = F * D;
    assign N1 = F * N;

    // Register the multiplication results
    reg18 reg_divisor_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D1[26:9]),     // Keep 18 bits
        .data_out(D2)
    );

    reg18 reg_dividend_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N1[26:9]),
        .data_out(N2)
    );

    dff1 ff2(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st2),
        .q     (st3)
    );

    // Stage 2: F1 = 2 - D2, multiply, register
    always_comb begin
        F1 = TWO - D2;
    end

    assign D3 = F1 * D2;
    assign N3 = F1 * N2;

    // Register the multiplication results
    reg18 reg_divisor_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D3[26:9]),
        .data_out(D4)
    );

    reg18 reg_dividend_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N3[26:9]),
        .data_out(N4)
    );

    dff1 ff3(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st3),
        .q     (st4)
    );

    // Stage 3: F2 = 2 - D4, multiply, register
    always_comb begin
        F2 = TWO - D4;
    end

    assign D5 = F2 * D4;
    assign N5 = F2 * N4;

    reg18 reg_divisor_stage4(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D5[26:9]),
        .data_out(D6)
    );

    reg18 reg_dividend_stage4(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N5[26:9]),
        .data_out(N6)
    );

    dff1 ff4(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st4),
        .q     (st5)
    );

    // Stage 4: F3 = 2 - D6, multiply, register
    always_comb begin
        F3 = TWO - D6;
    end

    assign D7 = F3 * D6;
    assign N7 = F3 * N6;

    reg18 reg_divisor_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D7[26:9]),
        .data_out(D8)
    );

    reg18 reg_dividend_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N7[26:9]),
        .data_out(N8)
    );

    dff1 ff6(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st5),
        .q     (st6)
    );

    // Stage 5: F4 = 2 - D8, multiply, register
    always_comb begin
        F4 = TWO - D8;
    end

    assign D9 = F4 * D8;
    assign N9 = F4 * N8;

    reg18 reg_divisor_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D9[26:9]),
        .data_out(D10)
    );
    reg18 reg_dividend_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N9[26:9]),
        .data_out(N10)
    );

    dff1 ff8(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st6),
        .q     (st7)
    );

    // Stage 6: F5 = 2 - D10, multiply, register
    always_comb begin
        F5 = TWO - D10;
    end

    assign D11 = F5 * D10;
    assign N11 = F5 * N10;

    reg18 reg_divisor_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D11[26:9]),
        .data_out(D12)
    );
    reg18 reg_dividend_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N11[26:9]),
        .data_out(N12)
    );

    dff1 ff9(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st7),
        .q     (st8)
    );

    // Stage 7: F6 = 2 - D12, multiply, register
    always_comb begin
        F6 = TWO - D12;
    end

    assign D13 = F6 * D12;
    assign N13 = F6 * N12;

    reg18 reg_divisor_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D13[26:9]),
        .data_out(D14)
    );
    reg18 reg_dividend_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N13[26:9]),
        .data_out(N14)
    );

    dff1 ff10(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st8),
        .q     (st9)
    );

    // Stage 8: F7 = 2 - D14, multiply, register
    always_comb begin
        F7 = TWO - D14;
    end

    assign D15 = F7 * D14;
    assign N15 = F7 * N14;

    reg18 reg_divisor_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D15[26:9]),
        .data_out(D16)
    );
    reg18 reg_dividend_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N15[26:9]),
        .data_out(N16)
    );

    dff1 ff11(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st9),
        .q     (st10)
    );

    // Stage 9: F8 = 2 - D16, multiply, register
    always_comb begin
        F8 = TWO - D16;
    end

    assign D17 = F8 * D16;
    assign N17 = F8 * N16;

    reg18 reg_divisor_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D17[26:9]),
        .data_out(D18)
    );
    reg18 reg_dividend_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N17[26:9]),
        .data_out(N18)
    );

    dff1 ff12(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st10),
        .q     (st11)
    );

    // Stage 10: F9 = 2 - D18, multiply, register
    always_comb begin
        F9 = TWO - D18;
    end

    assign D19 = F9 * D18;
    assign N19 = F9 * N18;

    reg18 reg_divisor_stage11(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D19[26:9]),
        .data_out(D20)
    );
    reg18 reg_dividend_stage11(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N19[26:9]),
        .data_out(N20)
    );

    dff1 ff13(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st11),
        .q     (st12)
    );

    always_comb begin
        N21 = N20;
    end

    // Final output register
    reg18 reg_quotient_out(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N21),
        .data_out(dv_out)
    );

    // Final pipeline control
    dff1 ff14(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st12),
        .q     (valid)
    );

    // Optimization: Combine stages 9 and 10 using a single register
    reg18 reg_combined_stage(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N20),
        .data_out(dv_out)
    );

    // Combine the last two stages into one register to reduce latency
    always_comb begin
        assign dv_out = reg_combined_stage(N20);
    end

endmodule
