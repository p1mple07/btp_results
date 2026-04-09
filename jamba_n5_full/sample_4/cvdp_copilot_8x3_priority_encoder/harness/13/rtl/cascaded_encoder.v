module cascaded_encoder #(parameter N = 8) (
    input [N-1:0] input_signal,
    output reg [M-1:0] out,
    output reg [M-2:0] out_upper_half,
    output reg [M-2:0] out_lower_half
);

    integer mid = N / 2;

    priority_encoder #(N) p1 (
        .input_signal([mid:0], input_signal),
        .out([M-1:0], out
    );

    priority_encoder #(N) p2 (
        .input_signal([0:mid-1], input_signal),
        .out([M-1:0], out_upper_half
    );

    always @(*) begin
        out = 0;
        if (out_upper_half)
            out = M-1;
        else if (out_lower_half)
            out = M-2;
    end

endmodule
