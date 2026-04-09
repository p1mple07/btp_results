module montgomery_mult #
(
    parameter N = 7,              
    parameter R = 8,              
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N)
)
(
    input clk,
    input rst_n,
    input  wire [NWIDTH-1:0] a,
    input  wire [NWIDTH-1:0] b,
    input valid_in,
    output wire [NWIDTH-1:0] result,
    output valid_out
);

    // Precompute R^2 mod N (as defined in the original code)
    localparam R_MOD_N = R % N;
    localparam TWO_NWIDTH = $clog2(2*N);

    reg [NWIDTH-1:0] a_q, b_q;
    reg [NWIDTH-1:0] a_redc_q, b_redc_q;
    reg [NWIDTH-1:0] result_q;

    wire [NWIDTH-1:0] a_redc, b_redc;
    wire [NWIDTH-1:0] result_d;
    wire [NWIDTH-1:0] result_final;

    // Pipeline registers for valid signal with a 4-cycle latency
    reg valid_in_q, valid_in_q1, valid_in_q2, valid_in_q3;
    reg valid_out_q;

    // Transform inputs to Montgomery form:
    // a' = montgomery_redc(a * R^2) and b' = montgomery_redc(b * R^2)
    // (Note: Using R_MOD_N as in the original code)
    wire [2*NWIDTH-1:0] ar = a_q * R_MOD_N;
    wire [2*NWIDTH-1:0] br = b_q * R_MOD_N;
    wire [2*NWIDTH-1:0] a_redc_x_b_redc = a_redc_q * b_redc_q;

    assign result = result_q;
    assign valid_out = valid_out_q;

    // Pipeline for valid signal with 4 clock cycles latency
    always_ff @(posedge clk or negedge rst_n) begin : valid_out_pipeline
        if (!rst_n) begin
            valid_in_q   <= 0;
            valid_in_q1  <= 0;
            valid_in_q2  <= 0;
            valid_in_q3  <= 0;
            valid_out_q  <= 0;
        end else begin
            valid_in_q   <= valid_in;
            valid_in_q1  <= valid_in_q;
            valid_in_q2  <= valid_in_q1;
            valid_in_q3  <= valid_in_q2;
            valid_out_q  <= valid_in_q3;
        end
    end

    // Input registers: capture a and b when valid_in is asserted
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

    // Pipeline registers for Montgomery reduced values of a and b
    always_ff @(posedge clk or negedge rst_n) begin : a_b_reduction_pipeline
        if (!rst_n) begin
            a_redc_q <= 0;
            b_redc_q <= 0;
        end else begin
            a_redc_q <= a_redc;
            b_redc_q <= b_redc;
        end
    end

    // Output register: register the final result after conversion from Montgomery form
    always_ff @(posedge clk or negedge rst_n) begin : output_register
        if (!rst_n) begin
            result_q <= 0;
        end else begin
            result_q <= result_final;
        end
    end

    // Compute Montgomery reduction for a' = montgomery_redc(a * R^2)
    montgomery_redc #
    (
        .N(N),
        .R(R),
        .R_INVERSE(R_INVERSE)
    ) ar2_redc (
        .T(ar),
        .result(a_redc)
    );

    // Compute Montgomery reduction for b' = montgomery_redc(b * R^2)
    montgomery_redc #
    (
        .N(N),
        .R(R),
        .R_INVERSE(R_INVERSE)
    ) br2_redc (
        .T(br),
        .result(b_redc)
    );

    // Compute intermediate product and its Montgomery reduction:
    // result' = montgomery_redc(a' * b')
    montgomery_redc #
    (
        .N(N),
        .R(R),
        .R_INVERSE(R_INVERSE)
    ) prod_redc (
        .T(a_redc_x_b_redc),
        .result(result_d)
    );

    // Final Montgomery reduction to convert result' back to standard form:
    // result = montgomery_redc(result')
    montgomery_redc #
    (
        .N(N),
        .R(R),
        .R_INVERSE(R_INVERSE)
    ) final_redc (
        .T(result_d),
        .result(result_final)
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