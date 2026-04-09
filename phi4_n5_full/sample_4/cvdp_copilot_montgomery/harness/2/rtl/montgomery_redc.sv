module montgomery_mult #
(
    parameter N = 7,              
    parameter R = 8,              
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N),
    parameter TWIDTH = $clog2(N*R)
)
(
    input clk,
    input rst_n,
    input  wire [NWIDTH-1:0] a, b,
    input valid_in,
    output wire [NWIDTH-1:0] result,
    output valid_out
);

    //--------------------------------------------------------------------------
    // Issue Fix 1: Precompute R^2 mod N (instead of R mod N)
    //--------------------------------------------------------------------------
    localparam [TWIDTH-1:0] R2         = R * R;
    localparam [TWIDTH-1:0] R2_MOD_N   = R2 % N;
    localparam TWO_NWIDTH         = $clog2(2*N);

    //--------------------------------------------------------------------------
    // Pipeline registers for input values
    //--------------------------------------------------------------------------
    reg [NWIDTH-1:0] a_q, b_q;

    //--------------------------------------------------------------------------
    // Registers for Montgomery-reduced values of a and b
    //--------------------------------------------------------------------------
    wire [NWIDTH-1:0] a_redc, b_redc;
    reg  [NWIDTH-1:0] a_redc_q, b_redc_q;

    //--------------------------------------------------------------------------
    // Compute product of reduced a and b
    //--------------------------------------------------------------------------
    wire [2*NWIDTH-1:0] a_redc_x_b_redc;

    //--------------------------------------------------------------------------
    // Intermediate and final result signals
    //--------------------------------------------------------------------------
    wire [NWIDTH-1:0] result_d;      // Result from product reduction
    wire [NWIDTH-1:0] result_final;  // Final conversion from Montgomery form

    // Additional register stage to match valid_out latency
    reg  [NWIDTH-1:0] result_q, result_q_final;

    //--------------------------------------------------------------------------
    // Pipeline for valid signal (latency = 4 cycles)
    //--------------------------------------------------------------------------
    reg valid_in_q, valid_in_q1, valid_in_q2, valid_out_q;
    assign valid_out = valid_out_q;

    always_ff @(posedge clk or negedge rst_n) begin : valid_out_pipeline
        if (!rst_n) begin
            valid_in_q      <= 0;
            valid_in_q1     <= 0;
            valid_in_q2     <= 0;
            valid_out_q     <= 0;
        end else begin
            valid_in_q      <= valid_in;
            valid_in_q1     <= valid_in_q;
            valid_in_q2     <= valid_in_q1;
            valid_out_q     <= valid_in_q2;
        end 
    end

    //--------------------------------------------------------------------------
    // Register inputs when valid
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin : input_registers
        if (!rst_n) begin
            a_q <= 0;
            b_q <= 0;
        end else begin
            if (valid_in) begin
                a_q <= a;
                b_q <= b;
            end
        end 
    end

    //--------------------------------------------------------------------------
    // Pipeline stage: register the Montgomery reductions of a and b
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin : a_b_reduction_pipeline
        if (!rst_n) begin
            a_redc_q <= 0;
            b_redc_q <= 0;
        end else begin
            a_redc_q <= a_redc;
            b_redc_q <= b_redc;
        end 
    end

    //--------------------------------------------------------------------------
    // Pipeline stage: register the final result with an extra stage to match valid_out latency
    //--------------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin : output_register
        if (!rst_n) begin
            result_q      <= 0;
            result_q_final<= 0;
        end else begin
            result_q      <= result_final;  // from final conversion stage
            result_q_final<= result_q;
        end 
    end
    assign result = result_q_final;

    //--------------------------------------------------------------------------
    // Compute transformed inputs in Montgomery form using R^2 mod N
    //--------------------------------------------------------------------------
    wire [2*NWIDTH-1:0] ar = a_q * R2_MOD_N;
    wire [2*NWIDTH-1:0] br = b_q * R2_MOD_N;

    // Combine the reduced values to form the product
    assign a_redc_x_b_redc = a_redc_q * b_redc_q;

    //--------------------------------------------------------------------------
    // Issue Fix 1: Final conversion stage missing.
    // The algorithm requires a final Montgomery reduction to convert from Montgomery form
    // back to standard representation.
    //--------------------------------------------------------------------------
    // First, perform Montgomery reduction on the product to get an intermediate result.
    montgomery_redc #
    (
        .N (N),
        .R (R),
        .R_INVERSE(R_INVERSE),
        .NWIDTH(NWIDTH),
        .TWIDTH(TWIDTH)
    ) prod_redc (
        .T(a_redc_x_b_redc),    
        .result(result_d)
    );

    // Zero-extend result_d to TWIDTH bits for the final conversion.
    wire [TWIDTH-1:0] final_T = { {(TWIDTH - NWIDTH){1'b0}}, result_d };
    montgomery_redc #
    (
        .N (N),
        .R (R),
        .R_INVERSE(R_INVERSE),
        .NWIDTH(NWIDTH),
        .TWIDTH(TWIDTH)
    ) final_redc (
        .T(final_T),    
        .result(result_final)
    );

    //--------------------------------------------------------------------------
    // Montgomery reduction instances for transformed inputs
    //--------------------------------------------------------------------------
    montgomery_redc #
    (
        .N (N),
        .R (R),
        .R_INVERSE(R_INVERSE),
        .NWIDTH(NWIDTH),
        .TWIDTH(TWIDTH)
    ) ar2_redc (
        .T(ar),    
        .result(a_redc)
    );
    
    montgomery_redc #
    (
        .N (N),
        .R (R),
        .R_INVERSE(R_INVERSE),
        .NWIDTH(NWIDTH),
        .TWIDTH(TWIDTH)
    ) br2_redc (
        .T(br),    
        .result(b_redc)
    );

endmodule


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
    // Derived parameters
    localparam RWIDTH           = $clog2(R);          
    localparam TWO_NWIDTH       = $clog2(2*N);              
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