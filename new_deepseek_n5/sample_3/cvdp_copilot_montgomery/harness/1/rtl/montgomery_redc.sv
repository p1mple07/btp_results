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
    localparam RWIDTH = $clog2(R)+1;         
              
    localparam [RWIDTH-1:0] R_INVERSE = (N_PRIME); // Corrected to use R_INVERSE

    wire [RWIDTH-1:0] T_mod_R;               
    wire [2*RWIDTH-1:0] T_mod_R_X_R_INVERSE;  // Fixed wire width to 16 bits
    wire [NWIDTH:0] t;                      

    assign T_mod_R = T[RWIDTH-1:0]; 

    assign T_mod_R_X_R_INVERSE = T_mod_R * R_INVERSE;

    assign m = T_mod_R_X_R_INVERSE[RWIDTH-1:0];

    assign t = (T + m * N) >> RWIDTH;

    assign result = (t >= N) ? (t - N) : t;

endmodule