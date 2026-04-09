
////////////////////////////////////////////////
// Optimized Gold-Schmidt Division Module
////////////////////////////////////////////////
module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,  // unsigned
    input  logic [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
    output logic         valid
);

    //////////////////////////////////////////////
    // Local parameters
    //////////////////////////////////////////////
    localparam logic [17:0] TWO  = 18'b000000010_000000000;  // "2.0" in Q9.9
    localparam logic [17:0] ZERO = 18'b000000000_000000000;  // "0.0" in Q9.9

    //////////////////////////////////////////////
    // Internal signals
    //////////////////////////////////////////////
    logic [17:0] D_0, N_0;
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [17:0] F, F1, F2, F3, F4, F5, F6, F7, F8, F9;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    // Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    //////////////////////////////////////////////
    // Pre-registers for dividend/divisor
    //////////////////////////////////////////////
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
    // Reduced pipeline stages and combined logic for optimization
    always_comb begin : SHIFT_AND_MULTIPLY
        // Calculate prescaled values and common factors in one step
        if (dividend[17]) begin
            prescaled_dividend = dividend >> 9;
            prescaled_divisor = divisor >> 9;
            F = TWO - prescaled_divisor;
        end else if (dividend[16]) begin
            prescaled_dividend = dividend >> 8;
            prescaled_divisor = divisor >> 8;
            F = TWO - prescaled_divisor;
        end else if (dividend[15]) begin
            prescaled_dividend = dividend >> 7;
            prescaled_divisor = divisor >> 7;
            F = TWO - prescaled_divisor;
        end else if (dividend[14]) begin
            prescaled_dividend = dividend >> 6;
            prescaled_divisor = divisor >> 6;
            F = TWO - prescaled_divisor;
        end else if (dividend[13]) begin
            prescaled_dividend = dividend >> 5;
            prescaled_divisor = divisor >> 5;
            F = TWO - prescaled_divisor;
        end else if (dividend[12]) begin
            prescaled_dividend = dividend >> 4;
            prescaled_divisor = divisor >> 4;
            F = TWO - prescaled_divisor;
        end else if (dividend[11]) begin
            prescaled_dividend = dividend >> 3;
            prescaled_divisor = divisor >> 3;
            F = TWO - prescaled_divisor;
        end else if (dividend[10]) begin
            prescaled_dividend = dividend >> 2;
            prescaled_divisor = divisor >> 2;
            F = TWO - prescaled_divisor;
        end else if (dividend[9]) begin
            prescaled_dividend = dividend >> 1;
            prescaled_divisor = divisor >> 1;
            F = TWO - prescaled_divisor;
        end else begin
            prescaled_dividend = dividend;
            prescaled_divisor = divisor;
            F = TWO - prescaled_divisor;
        end
    end

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

    // Stage 1: Compute F = (2 - D), multiply, register
    reg18 reg_divisor_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D[26:9]),
        .data_out(D2)
    );

    reg18 reg_dividend_stage2(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N[26:9]),
        .data_out(N2)
    );

    dff1 ff1(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st1),
        .q     (st2)
    );

    // Stage 2: F1 = 2 - D2, multiply, register
    reg18 reg_divisor_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D2[26:9]),
        .data_out(D3)
    );

    reg18 reg_dividend_stage3(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N2[26:9]),
        .data_out(N3)
    );

    dff1 ff2(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st2),
        .q     (st3)
    );

    // Stage 3: F2 = 2 - D3, multiply, register
    reg18 reg_divisor_stage4(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D3[26:9]),
        .data_out(D4)
    );

    reg18 reg_dividend_stage4(
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

    // Stage 4: F3 = 2 - D4, multiply, register
    reg18 reg_divisor_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D4[26:9]),
        .data_out(D5)
    );

    reg18 reg_dividend_stage5(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N4[26:9]),
        .data_out(N5)
    );

    dff1 ff4(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st4),
        .q     (st5)
    );

    // Stage 5: F4 = 2 - D5, multiply, register
    reg18 reg_divisor_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D5[26:9]),
        .data_out(D6)
    );

    reg18 reg_dividend_stage6(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N5[26:9]),
        .data_out(N6)
    );

    dff1 ff5(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st5),
        .q     (st6)
    );

    // Stage 6: F5 = 2 - D6, multiply, register
    reg18 reg_divisor_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D6[26:9]),
        .data_out(D7)
    );

    reg18 reg_dividend_stage7(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N6[26:9]),
        .data_out(N7)
    );

    dff1 ff6(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st6),
        .q     (st7)
    );

    // Stage 7: F6 = 2 - D7, multiply, register
    reg18 reg_divisor_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D7[26:9]),
        .data_out(D8)
    );

    reg18 reg_dividend_stage8(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N7[26:9]),
        .data_out(N8)
    );

    dff1 ff7(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st7),
        .q     (st8)
    );

    // Stage 8: F7 = 2 - D8, multiply, register
    reg18 reg_divisor_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D8[26:9]),
        .data_out(D9)
    );

    reg18 reg_dividend_stage9(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N8[26:9]),
        .data_out(N9)
    );

    dff1 ff8(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st8),
        .q     (st9)
    );

    // Stage 9: F8 = 2 - D9, multiply, register
    reg18 reg_divisor_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D9[26:9]),
        .data_out(D10)
    );
    reg18 reg_dividend_stage10(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N9[26:9]),
        .data_out(N10)
    );

    dff1 ff9(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st9),
        .q     (st10)
    );

    // Stage 10: F9 = 2 - D10, multiply, register
    reg18 reg_divisor_stage11(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D10[26:9]),
        .data_out(D11)
    );
    reg18 reg_dividend_stage11(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N10[26:9]),
        .data_out(N11)
    );

    dff1 ff10(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st10),
        .q     (st11)
    );

    // Stage 11: F10 = 2 - D11, multiply, register
    reg18 reg_divisor_stage12(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(D11[26:9]),
        .data_out(D12)
    );
    reg18 reg_dividend_stage12(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N11[26:9]),
        .data_out(N12)
    );

    dff1 ff11(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st11),
        .q     (st12)
    );

    // Final output register
    reg18 reg_quotient_out(
        .clk   (clk),
        .reset (~rst_n),
        .data_in(N12),
        .data_out(dv_out)
    );

    // Final pipeline control
    dff1 ff12(
        .clk   (clk),
        .reset (~rst_n),
        .d     (st12),
        .q     (valid)
    );

endmodule
