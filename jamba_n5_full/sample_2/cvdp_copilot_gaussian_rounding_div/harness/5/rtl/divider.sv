//////////////////////////////////////////////
// Top‑level Gold‑Schmidt division module
//////////////////////////////////////////////
module divider (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic [17:0]  dividend,
    input  logic [17:0]  divisor,
    output logic [17:0]  dv_out,
    output logic         valid
);

    // Prescaler for 18‑bit fixed‑point division
    module pre_scaler (
        input  logic [17:0] a,
        input  logic [17:0] c,
        output logic [17:0] b,
        output logic [17:0] d
    );
        always_comb begin
            b = a >> 9;
            d = c >> 9;
        end
    endmodule

    pre_scaler uut (.a(dividend), .c(divisor), .b(dividend_p), .d(divisor_p));

    assign dividend = dividend_p;
    assign divisor = divisor_p;

    // Gold‑Schmidt division stages (10 iterations)
    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            dv_out <= 18'h00;
            valid <= 1'b0;
        end else begin
            if (start) begin
                // Initial state
                logic [17:0] N, D, F;
                N = dividend;
                D = divisor;
                F = 2 - D;          // F_0 = 2 - D_0

                // Perform 10 iterations
                for (int i = 0; i < 10; i++) begin
                    F = 2 - D;
                    D = F * D;
                    N = F * N;
                    N = N >> 1;
                    D = D >> 1;
                end

                // Final quotient
                dv_out <= N;
                valid <= 1'b1;
            end
        end
    end

endmodule
