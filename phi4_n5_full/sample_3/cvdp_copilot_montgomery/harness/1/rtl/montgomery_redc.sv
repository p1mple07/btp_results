module montgomery_redc #
(
    parameter N = 7,              
    parameter R = 8,              
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N), 
    parameter TWIDTH = $clog2(N*R)     
)(
    input  wire [TWIDTH-1:0] T,    
    output wire [NWIDTH-1:0] result 
);
    // Derived parameters
    // FIX: Use $clog2(R) directly since R is a power of 2.
    localparam RWIDTH = $clog2(R);         

    // Compute N_PRIME from the equation: R * R_INVERSE - N * N_PRIME = 1
    localparam [RWIDTH-1:0] N_PRIME = (R * R_INVERSE - 1) / N;       

    wire [RWIDTH-1:0] T_mod_R;               
    wire [2*RWIDTH-1:0] T_mod_R_X_N_PRIME;      
    wire [RWIDTH-1:0] m;                     
    wire [NWIDTH:0] t;                      

    // T_mod_R = T mod R (lower RWIDTH bits)
    assign T_mod_R = T[RWIDTH-1:0]; 

    // Multiply T_mod_R by N_PRIME
    assign T_mod_R_X_N_PRIME = T_mod_R * N_PRIME;

    // m = (T_mod_R * N_PRIME) mod R (take lower RWIDTH bits)
    assign m = T_mod_R_X_N_PRIME[RWIDTH-1:0];

    // Compute t = (T + m * N) / R (division by power-of-2 is a right shift)
    assign t = (T + m * N) >> RWIDTH;

    // Return t - N if t >= N, otherwise t
    assign result = (t >= N) ? (t - N) : t;

endmodule