module montgomery_mult #
(
    parameter N = 7,              
    parameter R = 8,              
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N), 
    parameter TWIDTH = $clog2(N*R)
)(
    input clk ,
    input rst_n,
    input  wire [NWIDTH-1:0] a,b, 
    input valid_in,  
    output wire [NWIDTH-1:0] result ,
    output valid_out
);

    localparam R_MOD_N = R % N;
    localparam TWO_NWIDTH = $clog2(2*N);

    reg [NWIDTH-1:0] a_q, b_q;
    reg [NWIDTH-1:0] a_redc, b_redc;
    reg [NWIDTH-1:0] a_redc_q, b_redc_q;
    reg [NWIDTH-1:0] result_d;
    reg [NWIDTH-1:0] result_q;

    wire [NWIDTH-1:0] R_sq = (R * R) % N;

    assign a_redc_q = a_q * R_sq;
    assign b_redc_q = b_q * R_sq;

    assign a_redc_q = a_redc_q * R_INVERSE;
    assign b_redc_q = b_redc_q * R_INVERSE;

    assign result_d = (a_redc_q * b_redc_q) * R_INVERSE;

    assign result = (result_d >= N) ? (result_d - N) : result_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_q <= 0;
        end else begin
            result_q <= result;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
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

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_redc <= 0;
            b_redc <= 0;
        end else begin
            a_redc <= a_redc;
            b_redc <= b_redc;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_q <= 0;
        end else begin
            result_q <= result_d;
        end
    end

endmodule
