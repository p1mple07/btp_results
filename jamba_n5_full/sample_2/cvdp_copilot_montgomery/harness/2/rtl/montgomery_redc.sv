module montgomery_mult #(
    parameter N = 7,
    parameter R = 8,
    parameter R_INVERSE = 1,
    parameter NWIDTH = $clog2(N),
    parameter TWIDTH = $clog2(N*R)
)(
    input clk,
    input rst_n,
    input  wire [NWIDTH-1:0] a,
    input valid_in,
    output wire [NWIDTH-1:0] result ,
    output valid_out
);

localparam R_MOD_N = R % N;
localparam TWO_NWIDTH = $clog2(2*N);

reg [NWIDTH-1:0] a_q, b_q;
reg [NWIDTH-1:0] a_redc_x_b_redc;
reg [NWIDTH-1:0] result_d;
reg [2*NWIDTH-1:0] T;

// ...

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_q <= 0;
        b_q <= 0;
        T <= 0;
        result_d <= 0;
        valid_out <= 1'b0;
    end else begin
        if (valid_in) begin
            a_q <= a;
            b_q <= b;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_redc_q <= 0;
        b_redc_q <= 0;
    end else begin
        a_redc_q <= a_redc;
        b_redc_q <= b_redc;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result_q <= 0;
    end else begin
        result_q <= result_d;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        T <= 0;
    end else begin
        T <= (T + m * N) >> RWIDTH;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 0;
    end else begin
        result <= (t >= N) ? (t - N) : t;
    end
end

always_comb begin
    result = (valid_in && valid_in_q) ? result_q : 0;
    valid_out <= (valid_in && valid_out_q) ? valid_in_q : 0;
end

assign valid_out_q = valid_out;

initial begin
    $readmemory(addr, data, 10);
    // etc.
end

endmodule
