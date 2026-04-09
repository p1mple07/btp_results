module priority_encoder_8x3 (
    input [7:0] in,
    output [2:0] out
);
    out = 0;
    for (int i = 7; i >= 0; i--)$
    if (in[i]) begin
        out = (3'b${i+1} ${i} ${i-1});
        break;
    end
end
endmodule