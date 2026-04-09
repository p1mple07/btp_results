// Insert code here for 10 stage Gold-Schmidt division algorithm

always_ff @(posedge clk) begin : GOLD_SCHMIDT_DIVISION
    if (rst_n) begin
        D_0 <= ZERO;
        N_0 <= ZERO;
        D <= ZERO;
        N <= ZERO;
        F <= ZERO;
        st1 <= 0;
        st2 <= 0;
        st3 <= 0;
        st4 <= 0;
        st5 <= 0;
        st6 <= 0;
        st7 <= 0;
        st8 <= 0;
        st9 <= 0;
        st10 <= 0;
        st11 <= 0;
        st12 <= 0;
        dv_out <= ZERO;
        valid <= 0;
    end else begin
        if (start) begin
            D_0 <= DIVIDEND_PRESCALING(dividend, 18);
            N_0 <= DIVIDEND_PRESCALING(dividend, 18);
            D <= DIVIDEND_PRESCALING(divisor, 18);
            N <= DIVIDEND_PRESCALING(divisor, 18);
            F <= 2 - D_0;
            st1 <= 1;
        end

        if (st1) begin
            D2 <= D_0 * F;
            N2 <= N_0 * F;
            D <= D2 >> 1;
            N <= N2 >> 1;
            st2 <= st1;
        end

        if (st2) begin
            D4 <= D2 * F;
            N4 <= N2 * F;
            D <= D4 >> 1;
            N <= N4 >> 1;
            st3 <= st2;
        end

        if (st3) begin
            D6 <= D4 * F;
            N6 <= N4 * F;
            D <= D6 >> 1;
            N <= N6 >> 1;
            st4 <= st3;
        end

        if (st4) begin
            D8 <= D6 * F;
            N8 <= N6 * F;
            D <= D8 >> 1;
            N <= N8 >> 1;
            st5 <= st4;
        end

        if (st5) begin
            D10 <= D8 * F;
            N10 <= N8 * F;
            D <= D10 >> 1;
            N <= N10 >> 1;
            st6 <= st5;
        end

        if (st6) begin
            D12 <= D10 * F;
            N12 <= N10 * F;
            D <= D12 >> 1;
            N <= N12 >> 1;
            st7 <= st6;
        end

        if (st7) begin
            D14 <= D12 * F;
            N14 <= N12 * F;
            D <= D14 >> 1;
            N <= N14 >> 1;
            st8 <= st7;
        end

        if (st8) begin
            D16 <= D14 * F;
            N16 <= N14 * F;
            D <= D16 >> 1;
            N <= N16 >> 1;
            st9 <= st8;
        end

        if (st9) begin
            D18 <= D16 * F;
            N18 <= N16 * F;
            D <= D18 >> 1;
            N <= N18 >> 1;
            st10 <= st9;
        end

        if (st10) begin
            D20 <= D18 * F;
            N20 <= N18 * F;
            D <= D20 >> 1;
            N <= N20 >> 1;
            st11 <= st10;
        end

        if (st11) begin
            D22 <= D20 * F;
            N22 <= N20 * F;
            D <= D22 >> 1;
            N <= N22 >> 1;
            st12 <= st11;
        end

        if (st12) begin
            D24 <= D22 * F;
            N24 <= N22 * F;
            D <= D24 >> 1;
            N <= N24 >> 1;
            st13 <= st12;
        end

        if (st13) begin
            D26 <= D24 * F;
            N26 <= N24 * F;
            D <= D26 >> 1;
            N <= N26 >> 1;
            st14 <= st13;
        end

        if (st14) begin
            D28 <= D26 * F;
            N28 <= N26 * F;
            D <= D28 >> 1;
            N <= N28 >> 1;
            st15 <= st14;
        end

        if (st15) begin
            D30 <= D28 * F;
            N30 <= N28 * F;
            D <= D30 >> 1;
            N <= N30 >> 1;
            st16 <= st15;
        end

        if (st16) begin
            D32 <= D30 * F;
            N32 <= N30 * F;
            D <= D32 >> 1;
            N <= N32 >> 1;
            st17 <= st16;
        end

        if (st17) begin
            D34 <= D32 * F;
            N34 <= N32 * F;
            D <= D34 >> 1;
            N <= N34 >> 1;
            st18 <= st17;
        end

        if (st18) begin
            D36 <= D34 * F;
            N36 <= N34 * F;
            D <= D36 >> 1;
            N <= N36 >> 1;
            st19 <= st18;
        end

        if (st19) begin
            D38 <= D36 * F;
            N38 <= N36 * F;
            D <= D38 >> 1;
            N <= N38 >> 1;
            st20 <= st19;
        end

        if (st20) begin
            D40 <= D38 * F;
            N40 <= N38 * F;
            D <= D40 >> 1;
            N <= N40 >> 1;
            st21 <= st20;
        end

        if (st21) begin
            D42 <= D40 * F;
            N42 <= N40 * F;
            D <= D42 >> 1;
            N <= N42 >> 1;
            st22 <= st21;
        end

        if (st22) begin
            D44 <= D42 * F;
            N44 <= N42 * F;
            D <= D44 >> 1;
            N <= N44 >> 1;
            st23 <= st22;
        end

        if (st23) begin
            D46 <= D44 * F;
            N46 <= N44 * F;
            D <= D46 >> 1;
            N <= N46 >> 1;
            st24 <= st23;
        end

        if (st24) begin
            D48 <= D46 * F;
            N48 <= N46 * F;
            D <= D48 >> 1;
            N <= N48 >> 1;
            st25 <= st24;
        end

        if (st25) begin
            D50 <= D48 * F;
            N50 <= N48 * F;
            D <= D50 >> 1;
            N <= N50 >> 1;
            st26 <= st25;
        end

        if (st26) begin
            dv_out <= (D50 >> 18) + (N50 >> 18);
            valid <= 1;
        end
    end
end

function logic [17:0] DIVIDEND_PRESCALING(input logic [17:0] a, b);
    return (a << 18) - b; // Shift dividend left by 18 bits and subtract divisor
endfunction

endmodule
