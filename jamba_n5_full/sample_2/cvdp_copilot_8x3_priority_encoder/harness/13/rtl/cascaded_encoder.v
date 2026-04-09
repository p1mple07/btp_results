// rtl/priority_encoder.v
module priority_encoder (
    input [N-1:0] input,
    output reg [M-1:0] out
);

always @(*) begin
    if (input[N-1])
        out = 3'b111;
    else if (input[N-2])
        out = 3'b110;
    // Continue with the remaining lower‑priority cases
end

endmodule
