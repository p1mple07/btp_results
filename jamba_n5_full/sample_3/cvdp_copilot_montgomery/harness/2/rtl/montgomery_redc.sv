module montgomery_mult #
(
    input clk,
    input rst_n,
    input  wire [NWIDTH-1:0] a,
    input  wire [NWIDTH-1:0] b,
    input  wire valid_in,
    output wire [NWIDTH-1:0] result,
    output valid_out
);

    localparam R_MOD_N = R % N;
    localparam TWO_NWIDTH = $clog2(2*N);

    reg [NWIDTH-1:0] a_q, b_q;
    reg [NWIDTH-1:0] a_redc_q, b_redc_q;

    wire [NWIDTH-1:0] a_redc, b_redc;
    wire [NWIDTH-1:0] a_redc_q, b_redc_q;

    wire [NWIDTH-1:0] result_d;
    reg [NWIDTH-1:0] result_q;

    wire valid_in_q, valid_in_q1, valid_in_q2;
    wire valid_out_q;

    // Combinational logic for Montgomery multiplication
    assign a_q = a * R_MOD_N;
    assign b_q = b * R_MOD_N;

    assign a_redc_q = a_q * R_MOD_N;
    assign b_redc_q = b_q * R_MOD_N;

    assign a_redc_x_b_redc = a_redc_q * b_redc_q;

    assign result_q = a_redc_x_b_redc * R_MOD_N;

    assign result = result_q;

    // Valid output with 4‑cycle delay
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid_in_q      <= 0;
            valid_in_q1     <= 0;
            valid_in_q2     <= 0;
            valid_out_q     <= 0;
        end else begin
            valid_in_q      <= valid_in        ;     
            valid_in_q1     <= valid_in_q      ;   
            valid_in_q2     <= valid_in_q1     ; 
            valid_out_q     <= valid_in_q2     ; 
        end
    end

endmodule
