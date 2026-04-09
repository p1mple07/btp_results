// Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Gold-Schmidt division stages
    always_comb begin : STAGE1
        F = TWO - D_0;
        D = F * D_0;
        N = F * N_0;
        st1 = ~st1;
    end

    always_comb begin : STAGE2
        F1 = TWO - D;
        D2 = F1 * D;
        N2 = F1 * N;
        st2 = ~st2;
    end

    always_comb begin : STAGE3
        F2 = TWO - D2;
        D4 = F2 * D2;
        N4 = F2 * N2;
        st3 = ~st3;
    end

    always_comb begin : STAGE4
        F3 = TWO - D4;
        D6 = F3 * D4;
        N6 = F3 * N4;
        st4 = ~st4;
    end

    always_comb begin : STAGE5
        F4 = TWO - D6;
        D8 = F4 * D6;
        N8 = F4 * N6;
        st5 = ~st5;
    end

    always_comb begin : STAGE6
        F5 = TWO - D8;
        D10 = F5 * D8;
        N10 = F5 * N8;
        st6 = ~st6;
    end

    always_comb begin : STAGE7
        F6 = TWO - D10;
        D12 = F6 * D10;
        N12 = F6 * N10;
        st7 = ~st7;
    end

    always_comb begin : STAGE8
        F7 = TWO - D12;
        D14 = F7 * D12;
        N14 = F7 * N12;
        st8 = ~st8;
    end

    always_comb begin : STAGE9
        F8 = TWO - D14;
        D16 = F8 * D14;
        N16 = F8 * N14;
        st9 = ~st9;
    end

    always_comb begin : STAGE10
        F9 = TWO - D16;
        D18 = F9 * D16;
        N18 = F9 * N16;
        st10 = ~st10;
    end

    // Output calculation
    always_comb begin : OUTPUT_CALC
        D1 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2};
        N1 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D3 = {D18, D16, D14, D12, D10, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N3 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D5 = {D3, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N5 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D7 = {D5, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N7 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D9 = {D7, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N9 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D11 = {D9, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N11 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D13 = {D11, D10, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N13 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D15 = {D13, D12, D10, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N15 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D17 = {D15, D14, D12, D10, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N17 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};
        D19 = {D17, D16, D14, D12, D10, D8, D6, D4, D2, D, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO, ZERO};
        N19 = {N18, N17, N16, N15, N14, N13, N12, N11, N10, N9, N8, N7, N6, N5, N4, N3, N2, N1};

        // Prescale dividend and divisor to 18-bit width
        d = d_prescaler_inst(d, pre_scaled_dividend);
        b = pre_scaled_divisor;

        // Perform division
        case ({st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12})
            10: dv_out = N1;
            default: dv_out = ZERO;
        endcase
    end

    // Set valid high on the completion of the division
    always_comb begin : VALID_SET
        valid = 1;
    end

endmodule

// Prescale module
module d_prescaler_inst (
    input  logic [17:0] a,
    input  logic [17:0] c,
    output logic [17:0] b,
    output logic [17:0] d
);
    // Prescale c to ensure it is less than 1
    b = c >> (a - 1);
    d = c << (18 - a);
endmodule
