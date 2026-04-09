////////////////////////////////////////////////
// Top-Level Gold-Schmidt Division Module
////////////////////////////////////////////////
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
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20, D22;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [17:0] F, F1, F2, F3, F4, F5, F6, F7, F8, F9;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    // Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Gold-Schmidt division stages
    always @(posedge clk) begin : GOLD_SCHMIDT
        if (rst_n) begin
            D_0 <= ZERO;
            N_0 <= ZERO;
            D <= ZERO;
            N <= ZERO;
            F <= TWO;
            valid <= 0;
        end else begin
            st1 <= start;
            D_0 <= D;
            N_0 <= N;
            if (st1) begin
                D <= D_0 * F;
                N <= N_0 * F;
                st2 <= st1;
            end else if (st2) begin
                D <= D2;
                N <= N2;
                st3 <= st2;
            end else if (st3) begin
                D <= D4;
                N <= N4;
                st4 <= st3;
            end else if (st4) begin
                D <= D6;
                N <= N6;
                st5 <= st4;
            end else if (st5) begin
                D <= D8;
                N <= N8;
                st6 <= st5;
            end else if (st6) begin
                D <= D10;
                N <= N10;
                st7 <= st6;
            end else if (st7) begin
                D <= D12;
                N <= N12;
                st8 <= st7;
            end else if (st8) begin
                D <= D14;
                N <= N14;
                st9 <= st8;
            end else if (st9) begin
                D <= D16;
                N <= N16;
                st10 <= st9;
            end else if (st10) begin
                D <= D18;
                N <= N18;
                st11 <= st10;
            end else if (st11) begin
                D <= D20;
                N <= N20;
                st12 <= st11;
            end else begin
                D1 <= D17;
                N1 <= N17;
                valid <= 1;
            end
        end
    end

endmodule


////////////////////////////////////////////////
// Pre-scaling (Prescaling) Module
////////////////////////////////////////////////
module pre_scaler (
    input  logic [17:0] a,  // unsigned divisor
    input  logic [17:0] c,  // unsigned dividend
    output logic [17:0] b,  // prescaled divisor
    output logic [17:0] d   // prescaled dividend
);

    always_comb begin : PRESCALER_LOGIC
        b <= c >> 9; // Right shift 9 bits for prescaling
        d <= a >> 9; // Right shift 9 bits for prescaling
    end

endmodule


////////////////////////////////////////////////
// 18-bit register (parallel load)
////////////////////////////////////////////////
module reg18 (
    input  logic        clk,
    input  logic        reset,
    input  logic [17:0] data_in,
    output logic [17:0] data_out
);
    always @(posedge clk or posedge reset) begin : REG_LOGIC
        if (reset) begin
            data_out <= 18'b0;
        end else begin
            data_out <= data_in;
        end
    end
endmodule

