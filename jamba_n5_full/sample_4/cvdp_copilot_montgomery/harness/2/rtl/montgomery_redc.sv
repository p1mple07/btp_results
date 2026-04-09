module montgomery_mult #
(
    input  wire [TWIDTH-1:0] T,    
    output wire [NWIDTH-1:0] result 
);

    // Local parameters
    localparam RWIDTH = $clog2(R);
    localparam TWO_NWIDTH = $clog2(2*N);
    localparam [RWIDTH-1:0] N_PRIME = (R * R_INVERSE - 1) / N;

    wire [RWIDTH-1:0] T_mod_R;
    wire [2*RWIDTH-1:0] T_mod_R_X_N_PRIME;
    wire [RWIDTH-1:0] m;
    wire [TWO_NWIDTH-1:0] t;

    assign T_mod_R = T[RWIDTH-1:0];
    assign T_mod_R_X_N_PRIME = T_mod_R * N_PRIME;
    assign m = T_mod_R_X_N_PRIME[RWIDTH-1:0];
    assign t = (T + m * N) >> RWIDTH;

    assign result = (t >= N) ? (t - N) : t;

endmodule
