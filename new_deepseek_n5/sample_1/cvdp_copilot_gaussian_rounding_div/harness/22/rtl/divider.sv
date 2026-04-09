Module
// - RTL/Lint: 10
// - Signals: 18-bit fixed-point dividend and divisor
// - Output: 18-bit fixed-point quotient

    module divider (
        input  logic         clk,
        input  logic         rst_n,
        input  logic [17:0] dividend,
        input  logic [17:0] divisor,
        output logic [17:0] dv_out,
        output logic         valid
    );

    localparam logic [17:0] TWO = 18'b000000010_000000000; // "2.0" in Q9.9
    localparam logic [17:0] ZERO = 18'b000000000_000000000; // "0.0" in Q9.9

    // Pre-scaling: only for magnitude < 1
    module pre_scaler (
        input  logic [17:0] a,
        input  logic [17:0] c,
        output logic [17:0] b,
        output logic [17:0] d
    );
        // For simplicity, if 'a' is large, we shift until it is < 1.0 in Q9.9 format
        // That means the integer bits of 'a' must be 0. We find how many leading bits
        // we need to shift out.
        
        always_comb begin : SHIFT_LOGIC
            // 'a' has 18 bits in total, where the top 9 bits are integer, bottom 9 bits are fractional.
            // We want the integer part of 'a' to be 0 => 'a[17:9]' should be zero after shifting.

            if (a[17]) begin
                b = a >> 8;
                d = c >> 8;
            end
            else if (a[16]) begin
                b = a >> 7;
                d = c >> 7;
            end
            else if (a[15]) begin
                b = a >> 6;
                d = c >> 6;
            end
            else if (a[14]) begin
                b = a >> 5;
                d = c >> 5;
            end
            else if (a[13]) begin
                b = a >> 4;
                d = c >> 4;
            end
            else if (a[12]) begin
                b = a >> 3;
                d = c >> 3;
            end
            else if (a[11]) begin
                b = a >> 2;
                d = c >> 2;
            end
            else if (a[10]) begin
                b = a >> 1;
                d = c >> 1;
            end
            else begin
                b = a;
                d = c;
            end
        end
    end

    // Stage 1: Compute F = 2 - D, multiply, register
    reg18 reg18_stage1 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(dividend),
        .data_out(N1)
    );

    dff1 ff1 (
        .clk(clk),
        .rst(~rst_n),
        .d(divisor),
        .q(D1)
    );

    // Stage 2: Multiply, register
    reg18 reg18_stage2 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D1[26:9]),
        .data_out(D2)
    );

    dff1 ff2 (
        .clk(clk),
        .rst(~rst_n),
        .d(N1),
        .q(N2)
    );

    // Stage 3: Multiply, register
    reg18 reg18_stage3 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D2[26:9]),
        .data_out(D3)
    );

    dff1 ff3 (
        .clk(clk),
        .rst(~rst_n),
        .d(N2),
        .q(N3)
    );

    // Stage 4: Multiply, register
    reg18 reg18_stage4 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D3[26:9]),
        .data_out(D4)
    );

    dff1 ff4 (
        .clk(clk),
        .rst(~rst_n),
        .d(N3),
        .q(N4)
    );

    // Stage 5: Multiply, register
    reg18 reg18_stage5 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D4[26:9]),
        .data_out(D5)
    );

    dff1 ff5 (
        .clk(clk),
        .rst(~rst_n),
        .d(N4),
        .q(N5)
    );

    // Stage 6: Multiply, register
    reg18 reg18_stage6 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D5[26:9]),
        .data_out(D6)
    );

    dff1 ff6 (
        .clk(clk),
        .rst(~rst_n),
        .d(N5),
        .q(N6)
    );

    // Stage 7: Multiply, register
    reg18 reg18_stage7 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D6[26:9]),
        .data_out(D7)
    );

    dff1 ff7 (
        .clk(clk),
        .rst(~rst_n),
        .d(N6),
        .q(N7)
    );

    // Stage 8: Multiply, register
    reg18 reg18_stage8 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D7[26:9]),
        .data_out(D8)
    );

    dff1 ff8 (
        .clk(clk),
        .rst(~rst_n),
        .d(N7),
        .q(N8)
    );

    // Stage 9: Multiply, register
    reg18 reg18_stage9 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D8[26:9]),
        .data_out(D9)
    );

    dff1 ff9 (
        .clk(clk),
        .rst(~rst_n),
        .d(N8),
        .q(N9)
    );

    // Stage 10: Multiply, register
    reg18 reg18_stage10 (
        .clk(clk),
        .rst(~rst_n),
        .data_in(D9[26:9]),
        .data_out(D10)
    );

    dff1 ff10 (
        .clk(clk),
        .rst(~rst_n),
        .d(N9),
        .q(N10)
    );

    // Final output register
    reg18 reg_quotient_out (
        .clk(clk),
        .rst(~rst_n),
        .data_in(N10),
        .data_out(dv_out)
    );

    // Final pipeline control
    dff1 ff11 (
        .clk(clk),
        .rst(~rst_n),
        .d(N10),
        .q(valid)
    );

    // Pre-scaler
    pre_scaler pre_scaler (
        .a(dividend),
        .c(divisor),
        .b(D10),
        .d(N10)
    );

    // Final output register
    reg18 reg_quotient_out (
        .clk(clk),
        .rst(~rst_n),
        .data_in(N10),
        .data_out(dv_out)
    );

    // Final pipeline control
    dff1 ff11 (
        .clk(clk),
        .rst(~rst_n),
        .d(N10),
        .q(valid)
    );
endmodule