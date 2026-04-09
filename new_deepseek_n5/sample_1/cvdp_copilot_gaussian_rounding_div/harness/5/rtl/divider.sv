Module
module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    //////////////////////////////////////////////
    // Local parameters
    //////////////////////////////////////////////
    localparam logic [17:0] TWO  = 18'b000000010_000000000;
    localparam logic [17:0] ZERO = 18'b000000000_000000000;

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

    // Pre-scaling module
    logic [17:0] scaled_divisor, scaled_dividend;

    // Single-bit DFF
    module dff1 (
        input  logic clk,
        input  logic reset,
        input  logic d,
        output logic q
    );
        // Insert code here for 1 bit parallel load register using D Flip Flop
    endmodule

    // 18-bit register (parallel load)
    module reg18 (
        input  logic        clk,
        input  logic        reset,
        input  logic [17:0] data_in,
        output logic [17:0] data_out
    );
        // Insert code here for 18 bit parallel load register using D Flip Flop
    endmodule

    // Pre-scaling logic
    module pre_scaler (
        input  logic [17:0] a,
        input  logic [17:0] c,
        output logic [17:0] b,
        output logic [17:0] d
    );

        always_comb begin : SHIFT_LOGIC
            // Scale divisor to be less than 1
            if (a > ZERO) begin
                b = a;
                integer shift = 0;
                while (b >= TWO) begin
                    b = b >> 1;
                    shift = shift + 1;
                end
            else
                b = ZERO;
            end

            // Scale dividend to be less than 1
            if (c > ZERO) begin
                d = c;
                integer shift = 0;
                while (d >= TWO) begin
                    d = d >> 1;
                    shift = shift + 1;
                end
            else
                d = ZERO;
            end
        end
    endmodule

    // Gold-Schmidt pipeline stages
    always logic valid = ONE;
    logic [17:0] D_next, N_next;

    // Stage 1
    st1: always begin
        if (start && valid) begin
            F = TWO - divisor;
            D_next = divisor * F;
            N_next = dividend * F;
            D = D_next;
            N = N_next;
            F1 = F;
            st1 = 1;
        end
    end

    // Stage 2
    st2: always begin
        if (start && valid && st1) begin
            F1 = TWO - D;
            D_next = D * F1;
            N_next = N * F1;
            D = D_next;
            N = N_next;
            F2 = F1;
            st2 = 1;
        end
    end

    // Stage 3
    st3: always begin
        if (start && valid && st2) begin
            F2 = TWO - D;
            D_next = D * F2;
            N_next = N * F2;
            D = D_next;
            N = N_next;
            F3 = F2;
            st3 = 1;
        end
    end

    // Stage 4
    st4: always begin
        if (start && valid && st3) begin
            F3 = TWO - D;
            D_next = D * F3;
            N_next = N * F3;
            D = D_next;
            N = N_next;
            F4 = F3;
            st4 = 1;
        end
    end

    // Stage 5
    st5: always begin
        if (start && valid && st4) begin
            F4 = TWO - D;
            D_next = D * F4;
            N_next = N * F4;
            D = D_next;
            N = N_next;
            F5 = F4;
            st5 = 1;
        end
    end

    // Stage 6
    st6: always begin
        if (start && valid && st5) begin
            F5 = TWO - D;
            D_next = D * F5;
            N_next = N * F5;
            D = D_next;
            N = N_next;
            F6 = F5;
            st6 = 1;
        end
    end

    // Stage 7
    st7: always begin
        if (start && valid && st6) begin
            F6 = TWO - D;
            D_next = D * F6;
            N_next = N * F6;
            D = D_next;
            N = N_next;
            F7 = F6;
            st7 = 1;
        end
    end

    // Stage 8
    st8: always begin
        if (start && valid && st7) begin
            F7 = TWO - D;
            D_next = D * F7;
            N_next = N * F7;
            D = D_next;
            N = N_next;
            F8 = F7;
            st8 = 1;
        end
    end

    // Stage 9
    st9: always begin
        if (start && valid && st8) begin
            F8 = TWO - D;
            D_next = D * F8;
            N_next = N * F8;
            D = D_next;
            N = N_next;
            F9 = F8;
            st9 = 1;
        end
    end

    // Stage 10
    st10: always begin
        if (start && valid && st9) begin
            F9 = TWO - D;
            D_next = D * F9;
            N_next = N * F9;
            D = D_next;
            N = N_next;
            F10 = F9;
            st10 = 1;
        end
    end

    // Final stage
    st11: always begin
        if (start && valid && st10) begin
            F10 = TWO - D;
            D_next = D * F10;
            N_next = N * F10;
            D = D_next;
            N = N_next;
            dv_out = N;
            valid = ONE;
            st11 = 1;
        end
    end

    endmodule