module priority_encoder #(parameter N=4, M=log2(N)) (
    input       [N-1:0] in     ,   // N input lines
    output reg  [M-1:0] out         // M output lines
);

always @(*) begin
    integer i;
    out = 0;
    for (i = 0; i < N; i++) begin
        if (in[i])
            out = i;
    end
end

endmodule

module cascaded_encoder #(parameter N=4) (
    input       [N-1:0] input_signal   ,
    output reg  [N-1:0] out            ,
    output reg  [N-2:0] out_upper_half,
    output reg  [N-2:0] out_lower_half
);

wire [N-1:0] upper_half;
wire [N-1:0] lower_half;
priority_encoder #(.N(N/2),.M(log2(N/2))) upper_pe (.in(input_signal[N-1:N/2]),.out(upper_half));
priority_encoder #(.N(N/2),.M(log2(N/2))) lower_pe (.in(input_signal[N/2-1:0]),.out(lower_half));
assign out = (input_signal[N-1] == 1)? upper_half : lower_half;
assign out_upper_half = upper_half[N-2:0];
assign out_lower_half = lower_half[N-2:0];

endmodule