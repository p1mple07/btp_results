module cascaded_encoder #(parameter N=8, M=$clog2(N)) (
    input wire logic [N-1:0] input_signal,
    output wire logic [M-1:0] out,
    output wire logic [M-2:0] out_upper_half,
    output wire logic [M-2:0] out_lower_half
);

localparam PW = $clog2(M); // Priority Width
wire logic [PW-1:0] prio_signal;

// Extract priority bits
always_comb begin
    integer i;
    prio_signal = 0;
    for (i = 0; i < N; ++i) begin
        prio_signal[i] = input_signal[i];
    end
end

priority_encoder #(.N(N),.M(M)) pe_upper_half (
   .input_signal(input_signal[N-1:N/2]),
   .out(out_upper_half),
   .out_of_range('0),
   .out_of_bound('0),
   .out_of_bound_first('0)
);

priority_encoder #(.N(N),.M(M)) pe_lower_half (
   .input_signal(input_signal[N/2-1:0]),
   .out(out_lower_half),
   .out_of_range('0),
   .out_of_bound('0),
   .out_of_bound_first('0)
);

priority_encoder #(.N((M+1)*(N/2)),.M(M)) pe_merged (
   .input_signal({ out_upper_half, out_lower_half }),
   .out(out)
);

endmodule