module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    localparam logic [17:0] TWO  = 18'b000000010_000000000;
    localparam logic [17:0] ZERO = 18'b000000000_000000000;

    logic [17:0] N, D, F;
    logic [17:0] N_prev, D_prev;

    initial begin
        N = dividend;
        D = divisor;
        N_prev = N;
        D_prev = D;
    end

    always_ff @(posedge clk) begin
        if (start) begin
            N_prev <= N;
            D_prev <= D;
            F = 2 - D;
            D = F * D;
            N = F * N;
        end
    end

    always_ff @(posedge clk) begin
        if (~start) begin
            dv_out = N;
            valid = 1'b1;
        end
    end

endmodule
