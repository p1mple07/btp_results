module rc5_enc_16bit(
    input wire clock,
    input wire reset,
    input wire enc_start,
    input wire [15:0] p,
    output reg [15:0] c
);

reg [7:0] s0, s1, s2, s3, s4, s5, s6, s7;
wire ca_out;

always_ff @(posedge clock) begin
    if (reset)
        s0 = 8'b11111111;
        s1 = 8'b11111111;
        s2 = 8'b11111111;
        s3 = 8'b11111111;
        s4 = 8'b11111111;
        s5 = 8'b11111111;
        s6 = 8'b11111111;
        s7 = 8'b11111111;
    else
        s0 = s1;
        s1 = s2;
        s2 = s3;
        s3 = s4;
        s4 = s5;
        s5 = s6;
        s6 = s7;
        s7 = s0;
    end
end

always_ff @(posedge clock)
begin
    if (enc_start)
    begin
        ca_out = s0 ^ s1 ^ s2 ^ s3 ^ s4 ^ s5 ^ s6 ^ s7;
        c = {s0, s1, s2, s3, s4, s5, s6, s7};
        enc_done = 1'b1;
    end
    else
    begin
        ca_out = s0 ^ s1 ^ s2 ^ s3 ^ s4 ^ s5 ^ s6 ^ s7;
        c = {s0, s1, s2, s3, s4, s5, s6, s7};
        enc_done = 1'b0;
    end
end

endmodule
