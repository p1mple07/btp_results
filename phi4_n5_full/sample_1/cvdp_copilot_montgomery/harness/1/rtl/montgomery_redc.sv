module montgomery_redc #
(
    parameter N = 7,              
    parameter R = 8,              
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N), 
    parameter TWIDTH = $clog2(N*R)     
)
(
    input  wire [TWIDTH-1:0] T,    
    output wire [NWIDTH-1:0] result 
);

    // Use LOG_R = log2(R) instead of log2(R)+1 for proper bit widths
    localparam LOG_R = $clog2(R);

    // Compute N' = (R * R_INVERSE - 1) / N with the correct width
    localparam [LOG_R-1:0] N_PRIME = (R * R_INVERSE - 1) / N;       

    // Intermediate wires
    wire [LOG_R-1:0] T_mod_R;               
    wire [2*LOG_R-1:0] T_mod_R_X_N_PRIME;      
    wire [LOG_R-1:0] m;                     
    wire [NWIDTH:0] t;                      

    // Extract T mod R using LOG_R bits (since R is a power of 2)
    assign T_mod_R = T[LOG_R-1:0]; 

    // Compute m = (T mod R * N_PRIME) mod R
    assign T_mod_R_X_N_PRIME = T_mod_R * N_PRIME;
    assign m = T_mod_R_X_N_PRIME[LOG_R-1:0];

    // Compute t = (T + m * N) / R by shifting right by LOG_R bits
    assign t = (T + m * N) >> LOG_R;

    // If t >= N, subtract N; otherwise, t is the result
    assign result = (t >= N) ? (t - N) : t;

endmodule