module montgomery_mult #
(
    parameter N = 7,
    parameter R = 8,
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N)
)
(
    input  clk,
    input  rst_n,
    input  wire [NWIDTH-1:0] a,
    input  wire [NWIDTH-1:0] b,
    input  valid_in,
    output wire [NWIDTH-1:0] result,
    output valid_out
);

    // Instead of using R % N, compute R^2 mod N.
    localparam [NWIDTH-1:0] R2_MOD_N = (R * R) % N;
    localparam TWO_NWIDTH = $clog2(2*N);

    // Registers for input values.
    reg [NWIDTH-1:0] a_q, b_q;
    // Wires for Montgomery reduction outputs.
    wire [NWIDTH-1:0] a_redc, b_redc;
    reg [NWIDTH-1:0] a_redc_q, b_redc_q;

    // Wires for intermediate and final results.
    wire [NWIDTH-1:0] result_d;
    wire [NWIDTH-1:0] final_result;
    reg  [NWIDTH-1:0] result_q, result_q2;

    // Valid signal pipeline registers.
    reg valid_in_q, valid_in_q1, valid_in_q2, valid_in_q3;
    reg valid_out_q;

    // Transform inputs into Montgomery form.
    // Compute a' = montgomery_redc(a * R^2 mod N) and b' similarly.
    wire [2*NWIDTH-1:0] ar = a_q * R2_MOD_N;
    wire [2*NWIDTH-1:0] br = b_q * R2_MOD_N;

    // Pipeline the valid signal to achieve 4‐cycle latency.
    always_ff @(posedge clk or negedge rst_n) begin : valid_out_pipeline
        if (!rst_n) begin
            valid_in_q     <= 0;
            valid_in_q1    <= 0;
            valid_in_q2    <= 0;
            valid_in_q3    <= 0;
            valid_out_q    <= 0;
        end else begin
            valid_in_q     <= valid_in;
            valid_in_q1    <= valid_in_q;
            valid_in_q2    <= valid_in_q1;
            valid_in_q3    <= valid_in_q2;
            valid_out_q    <= valid_in_q3;
        end 
    end

    // Register the inputs.
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

    // Pipeline the Montgomery-reduced values.
    always_ff @(posedge clk or negedge rst_n) begin : a_b_reduction_pipeline
        if (!rst_n) begin
            a_redc_q <= 0;
            b_redc_q <= 0;
        end else begin
            a_redc_q <= a_redc;
            b_redc_q <= b_redc;
        end 
    end

    // Pipeline the final result so that it appears one cycle later than valid_out.
    always_ff @(posedge clk or negedge rst_n) begin : output_register
        if (!rst_n) begin
            result_q  <= 0;
            result_q2 <= 0;
        end else begin
            result_q  <= final_result;
            result_q2 <= result_q;
        end 
    end

    // Assign outputs.
    assign result = result_q2;
    assign valid_out = valid_out_q;

    // Instantiate Montgomery reduction for a and b.
    montgomery_redc #
    (
        .N            (N),
        .R            (R),
        .R_INVERSE    (R_INVERSE),
        .NWIDTH       (NWIDTH),
        .TWIDTH       (2*NWIDTH)  // a_q * R2_MOD_N yields 2*NWIDTH bits.
    ) ar2_redc (
        .T    (ar),
        .result (a_redc)
    );
    
    montgomery_redc #
    (
        .N            (N),
        .R            (R),
        .R_INVERSE    (R_INVERSE),
        .NWIDTH       (NWIDTH),
        .TWIDTH       (2*NWIDTH)
    ) br2_redc (
        .T    (br),
        .result (b_redc)
    );

    // Montgomery reduction for the product in Montgomery form.
    montgomery_redc #
    (
        .N            (N),
        .R            (R),
        .R_INVERSE    (R_INVERSE),
        .NWIDTH       (NWIDTH),
        .TWIDTH       (2*NWIDTH)
    ) prod_redc (
        .T    (a_redc_q * b_redc_q),
        .result (result_d)
    );

    // Final Montgomery reduction to convert the result out of Montgomery form.
    montgomery_redc #
    (
        .N            (N),
        .R            (R),
        .R_INVERSE    (R_INVERSE),
        .NWIDTH       (NWIDTH),
        .TWIDTH       (NWIDTH)   // result_d is NWIDTH bits.
    ) final_redc (
        .T    (result_d),
        .result (final_result)
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

    // Derived parameters.
    localparam RWIDTH     = $clog2(R);
    localparam TWO_NWIDTH = $clog2(2*N);
    localparam [RWIDTH-1:0] N_PRIME = (R * R_INVERSE - 1) / N;

    // Compute the Montgomery reduction.
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