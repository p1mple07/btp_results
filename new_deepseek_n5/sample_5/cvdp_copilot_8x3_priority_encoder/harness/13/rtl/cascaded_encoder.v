module priority_encoder (
    input wire [N-1:0] input_signal,
    output reg [M-1:0] out
);

    integer i;
    for (i = N-1; i >= 0; i = i-1) begin
        if (input_signal[i]) begin
            out = i;
            break;
        end
    end
    default out = 0;
endmodule

module cascaded_encoder (
    input wire [N-1:0] input_signal,
    output reg [M-1:0] out,
    output reg [M-2:0] out_upper_half,
    output reg [M-2:0] out_lower_half
);

    priority_encoder upper_encoder (.input(input_signal[M_upper:0]), .out(out_upper_half));
    priority_encoder lower_encoder (.input(input_signal[~M_upper:~0]), .out(out_lower_half));

    if (out_upper_half != 0) begin
        out = (out_upper_half << (M-2 - M_upper)) | out_lower_half;
    else begin
        out = out_lower_half;
    end
endmodule