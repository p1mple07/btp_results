module montgomery_redc #
(
    parameter N = 109,
    parameter R = 256,
    parameter R_INVERSE = 66,
    parameter NWIDTH = $clog2(N),
    parameter TWIDTH = $clog2(N*R)
)(
    input  wire [TWIDTH-1:0] T,    
    output wire [NWIDTH-1:0] result 
);
    // Derived parameters
    localparam RWIDTH = $clog2(R)+1;         
              
    localparam N_PRIME = (R * R_INVERSE - 1) / N;
    localparam [RWIDTH-1:0] R_INVERSE_LOW = R_INVERSE;
    localparam [RWIDTH-1:0] R_INVERSE_HIGH = (R_INVERSE >> RWIDTH);

    wire [RWIDTH-1:0] T_mod_R;               
    wire [2*RWIDTH-1:0] T_mod_R_X_N_PRIME;      
    wire [RWIDTH-1:0] m;                     
    wire [NWIDTH:0] t;                      

    assign T_mod_R = T[RWIDTH-1:0]; 

    assign T_mod_R_X_N_PRIME = T_mod_R * N_PRIME;

    assign m = T_mod_R_X_N_PRIME[RWIDTH-1:0];

    assign t = (T + m * N) >> RWIDTH;

    assign result = (t >= N) ? (t - N) : t;

endmodule