module cascaded_encoder #(
    parameter N = 8,
    parameter M = $clog2(N)
)(
    input [N-1:0] in,
    output [M-1:0] out,
    output out_upper_half [M-2:0],
    output out_lower_half [M-2:0]
);

    localparam half = N / 2;

    priority_encoder #(N) u_upper (@(posedge clk));
    priority_encoder #(N) u_lower (@(posedge clk));

    always_comb begin
        out = u_upper.out;
        out_upper_half = u_upper.out[M-2:M-2];
        out_lower_half = u_lower.out[M-2:M-2];
    end

endmodule
