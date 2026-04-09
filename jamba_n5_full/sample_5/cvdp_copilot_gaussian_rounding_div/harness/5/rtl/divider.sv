module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    // Prescaler for 9-bit fraction
    module pre_scaler (
        input logic [17:0] a,
        input logic [17:0] c,
        output logic [17:0] b,
        output logic [17:0] d
    );

        assign b = a >> 9;
        assign d = c >> 9;
    endmodule

    // Initialize prescaler with 9-bit shifts
    logic [17:0] D_0, N_0;
    pre_scaler inst_pre(
        .a(dividend),
        .c(divisor),
        .b(N_0),
        .d(D_0)
    );

    // Divider registers
    logic [17:0] D_prev, N_prev;
    logic [17:0] F, D, N;

    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            D_prev <= ZERO;
            N_prev <= ZERO;
            valid <= 0;
            dv_out <= X"00";
            return;
        end

        if (start) begin
            N_prev = N_0;
            D_prev = D_0;
        end else begin
            N_prev = dividend;
            D_prev = divisor;
        end

        for (int i = 0; i < 10; i++) begin
            F = 2 - D_prev;
            D = F * D_prev;
            N = F * N_prev;
            D_prev = D;
            N_prev = N;
        end

        dv_out = N;
        valid = 1;
    end

endmodule
