module priority_encoder (
    input  [N-1:0] in,
    output reg [M-1:0] out
);
    parameter N, M = log2(N);
    reg [M-1:0] result;
begin
    for (i = N-1; i >= 0; i = i-1) begin
        if (in[i]) begin
            result = (i+1)[M-1:0];
            break;
        end
    end
    out = result;
endmodule

module cascaded_encoder (
    input  [N-1:0] in,
    output reg [M-1:0] out,
    output reg [M-2:0] out_upper_half,
    output reg [M-2:0] out_lower_half
);
    parameter N, M = log2(N);
    wire [M-1:0] upper_half, lower_half;
    priority_encoder pe_upper (
        input  upper_half,
        output reg out_upper_half
    );
    priority_encoder pe_lower (
        input  lower_half,
        output reg out_lower_half
    );
begin
    upper_half = [N/2-1:0] in;
    lower_half = [N/2:0] in;
    
    if (out_upper_half != 0) begin
        out = out_upper_half;
    else begin
        out = out_lower_half;
    end
    out = out_upper_half | (out_lower_half << 1);
endmodule