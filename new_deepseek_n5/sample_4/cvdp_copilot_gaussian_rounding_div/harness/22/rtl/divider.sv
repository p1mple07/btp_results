module
// This module performs unsigned division of an 18-bit fixed-point 
// dividend by a given 18-bit fixed-point divisor, producing the corresponding quotient 
// (dv_out). The design implements an iterative Gold-Schmidt division algorithm ( pipeline stages optimized ).

// Constants
logic [17:0] TWO  = 18'b00000001000000000;  // "2.0" in Q9.9
logic [17:0] ZERO = 18'b000000000000000000;  // "0.0" in Q9.9

// Internal signals
module divider (
    input  logic  [17:0]  dividend,  // unsigned
    input  logic  [17:0]  divisor,   // unsigned
    output logic [17:0]  dv_out,
);

    // Local parameters
    localparam logic [17:0] TWO  = 18'b000000010000000000;  // "2.0" in Q9.9
    localparam logic [17:0] ZERO = 18'b000000000000000000;  // "0.0" in Q9.9

    // Internal signals
    reg18 reg18_st1, reg18 reg18_st2,
    reg18 reg18_st3, reg18 reg18_st4,
    reg18 reg18_st5, reg18 reg18_st6,
    reg18 reg18_st7, reg18 reg18_st8,
    reg18 reg18_st9, reg18 reg18_st10,
    reg18 reg18_st11, reg18 reg18_st12,
    reg18 reg18_st13, reg18 reg18_st14,
    reg18 reg18_st15, reg18 reg18_st16,
    reg18 reg18_st17, reg18 reg18_st18,
    reg18 reg18_st19, reg18 reg18_st20,
    reg18 reg18_st21,
    reg18 reg18_st22,
    reg18 reg18_st23,
    reg18 reg18_st24,
    reg18 reg18_st25,
    reg18 reg18_st26,
    reg18 reg18_st27,
    reg18 reg18_st28,
    reg18 reg18_st29,
    reg18 reg18_st30,
    reg18 reg18_st31
    // Pipeline control
    , shift_comb logic [17:0] shift_comb,
    // Stage 1: Compute F1 and multiply
    always_comb begin
        // F1 = 2 - D
        F1 = TWO - divisor;
    end

    // Stage 2: Multiply and register
    always_comb begin
        // D1 = F1 * D
        D1 = F1 * divisor;
        reg18 reg18_st1[0] = D1;
    end

    // Stage 3: Compute F2 and multiply
    always_comb begin
        // F2 = 2 - D1
        F2 = TWO - D1;
    end

    // Stage 4: Multiply and register
    always_comb begin
        // D2 = F2 * D1
        D2 = F2 * D1;
        reg18 reg18_st2[0] = D2;
    end

    // Stage 5: Compute F3 and multiply
    always_comb begin
        // F3 = 2 - D2
        F3 = TWO - D2;
    end

    // Stage 6: Multiply and register
    always_comb begin
        // D3 = F3 * D2
        D3 = F3 * D2;
        reg18 reg18_st3[0] = D3;
    end

    // Stage 7: Compute F4 and multiply
    always_comb begin
        // F4 = 2 - D3
        F4 = TWO - D3;
    end

    // Stage 8: Multiply and register
    always_comb begin
        // D4 = F4 * D3
        D4 = F4 * D3;
        reg18 reg18_st4[0] = D4;
    end

    // Stage 9: Compute F5 and multiply
    always_comb begin
        // F5 = 2 - D4
        F5 = TWO - D4;
    end

    // Stage 10: Multiply and register
    always_comb begin
        // D5 = F5 * D4
        D5 = F5 * D4;
        reg18 reg18_st5[0] = D5;
    end

    // Stage 11: Compute F6 and multiply
    always_comb begin
        // F6 = 2 - D5
        F6 = TWO - D5;
    end

    // Stage 12: Multiply and register
    always_comb begin
        // D6 = F6 * D5
        D6 = F6 * D5;
        reg18 reg18_st6[0] = D6;
    end

    // Final output register
    always_comb begin
        dv_out = reg18_st6[0];
    end
endmodule