////////////////////////////////////////////////
// Top‑Level Gold‑Schmidt Division Module
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

    // Pre‑scale the dividend and divisor to reduce them to the range 0…1
    logic [17:0] prescaled_dividend = divide_by_two(dividend);
    logic [17:0] prescaled_divisor   = divide_by_two(divisor);

    // Gold‑Schmidt iteration (10 stages)
    logic [17:0] D_prev, N_prev;
    logic [17:0] F_i, D_curr, N_curr, D_next, N_next;
    integer i;

    initial begin
        D_prev = prescaled_divisor;
        N_prev = prescaled_dividend;

        for (i = 0; i < 10; i = i + 1) begin : gs_loop
            F_i = 2'd1 - D_prev;          // F_i = 2 - D_{i-1}
            D_curr = F_i * D_prev;
            N_curr = F_i * N_prev;

            // Synchronous delay (simulated by #1)
            #1;

            D_prev = D_curr;
            N_prev = N_curr;
        endfor

        dv_out = N_prev;          // Quotient in 18‑bit format
        valid = 1'b1;             // Output is ready
    end

endmodule

////////////////////////////////////////////////
// Pre‑scaling helper (already implemented elsewhere)
////////////////////////////////////////////////
module divide_by_two (input logic [17:0] a);
    assign output = a / 2;
endmodule

////////////////////////////////////////////////
// Single‑bit D flip‑flop (already implemented elsewhere)
////////////////////////////////////////////////
module dff1 (input logic clk, input logic reset, input logic d, output logic q);
    always_comb begin
        q <= d;
    end
endmodule

////////////////////////////////////////////////
// 18‑bit register (parallel load) (already implemented elsewhere)
////////////////////////////////////////////////
module reg18 (input logic clk, input logic reset, input logic [17:0] data_in, output logic [17:0] data_out);
    always_comb begin
        data_out <= data_in;
    end
endmodule
