module priority_encoder #(parameter N=8)(
    input       [N-1:0] input_signal,
    output reg  [log2(N)-1:0] out // M = log2(N) bits
);
genvar i;
generate
for(i=N-1;i>=0;i--) begin : gen_bits
    assign out[i]=~input_signal[i];
end
endgenerate

endmodule

module cascaded_encoder #(parameter N=8)(
    input       [N-1:0] input_signal,
    output reg  [log2(N)-1:0] out, // M = log2(N) bits
    output reg  [log2(N)-2:0] out_upper_half,
    output reg  [log2(N)-2:0] out_lower_half
);
localparam M=log2(N);
reg [M-1:0] out_upper_half_reg;
reg [M-1:0] out_lower_half_reg;
wire [M-1:0] out_upper_half_wire;
wire [M-1:0] out_lower_half_wire;
priority_encoder #(.N(N/2)) upper_half_encoder(
   .input_signal(input_signal[N-1:N/2]),
   .out(out_upper_half_wire)
);
priority_encoder #(.N(N/2)) lower_half_encoder(
   .input_signal(input_signal[N/2-1:0]),
   .out(out_lower_half_wire)
);
assign out_upper_half_reg=out_upper_half_wire;
assign out_lower_half_reg=out_lower_half_wire;
assign out= {{M{1'b0}},out_upper_half_reg}&{{M{1'b0}},out_lower_half_reg};

endmodule