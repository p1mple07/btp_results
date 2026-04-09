module montgomery_redc #(
    parameter N = 7,
    parameter R = 8,
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N),
    parameter TWIDTH = $clog2(N*R)
) (
    input  wire [TWIDTH-1:0] T,
    output wire [NWIDTH-1:0] result
);
    // Derived parameters
    localparam RWIDTH = $clog2(R)+1;
    localparam N_PRIME = (R * R_INVERSE - 1) / N;

    wire [RWIDTH-1:0] T_mod_R = T[RWIDTH-1:0];
    wire [2*RWIDTH-1:0] T_mod_R_X_N_PRIME = T_mod_R * N_PRIME;
    wire [RWIDTH-1:0] m = T_mod_R_X_N_PRIME[RWIDTH-1:0];
    wire [NWIDTH:0] t = (T + m * N) >> RWIDTH;
    wire [NWIDTH-1:0] result = (t >= N)? (t - N) : t;

endmodule