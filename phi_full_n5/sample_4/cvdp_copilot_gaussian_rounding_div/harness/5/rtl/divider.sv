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
    logic [17:0] D, D2, D4, D6, D8, D10, D12, D14, D16, D18, D20;
    logic [17:0] N, N2, N4, N6, N8, N10, N12, N14, N16, N18, N20, N21;
    logic [47:0] D1, N1, D3, N3, D5, N5, D7, N7, D9, N9, D11, N11, D13, N13, D15, N15, D17, N17, D19, N19;

    // Pipeline stage flags
    logic st1, st2, st3, st4, st5, st6, st7, st8, st9, st10, st11, st12;

    // Instantiate pre-scaler module
    pre_scaler pre_scaler_inst(
        .clk(clk),
        .a(divisor),
        .c(dividend),
        .b(D_0),
        .d(N_0)
    );

    // Gold-Schmidt division stages
    always_comb begin : GOLD_SCHMIDT_STAGES
        st1 = ~start;
        N_0 = N_0 >> 1;
        D_0 = D_0 >> 1;
        
        D1 = TWO - D_0;
        N1 = TWO - N_0;
        N2 = N1 >> 1;
        D2 = D1 >> 1;

        D3 = TWO - D2;
        N3 = N2 >> 1;
        D4 = D3 >> 1;
        N4 = N3 >> 1;

        D5 = TWO - D4;
        N5 = N4 >> 1;
        D6 = D5 >> 1;
        N6 = N5 >> 1;

        D7 = TWO - D6;
        N7 = N6 >> 1;
        D8 = D7 >> 1;
        N8 = N7 >> 1;

        D9 = TWO - D8;
        N9 = N8 >> 1;
        D10 = D9 >> 1;
        N10 = N9 >> 1;

        D11 = TWO - D10;
        N11 = N10 >> 1;
        D12 = D11 >> 1;
        N12 = N11 >> 1;

        D13 = TWO - D12;
        N13 = N12 >> 1;
        D14 = D13 >> 1;
        N14 = N13 >> 1;

        D15 = TWO - D14;
        N15 = N14 >> 1;
        D16 = D15 >> 1;
        N16 = N15 >> 1;

        D17 = TWO - D16;
        N17 = N16 >> 1;
        D18 = D17 >> 1;
        N18 = N17 >> 1;

        D19 = TWO - D18;
        N19 = N18 >> 1;

        // Combine results from each stage
        D = D19;
        N = N19;
    end

    // Register the result and valid flag
    always_ff @(posedge clk) begin : RESULT_REG
        if (rst_n) begin
            dv_out <= ZERO;
            valid <= 0;
        end else if (st1) begin
            dv_out <= N;
            valid <= 1;
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

    always_comb begin : PRESCALING
        b = c >> 1;
        d = a >> 1;
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
    always_ff @(posedge clk) begin : PARALLEL_LOAD
        if (reset) begin
            data_out <= 18'b0;
        end else begin
            data_out <= data_in;
        end
    end
endmodule
