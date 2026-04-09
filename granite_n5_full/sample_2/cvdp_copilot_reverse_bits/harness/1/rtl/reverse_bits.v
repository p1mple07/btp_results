module reverse_bits (
    input wire [31:0] num_in,
    output reg [31:0] num_out
);

always @(*) begin
    num_out = 0;
    for (int i=0; i<32; i=i+1) begin
        num_out[i] = num_in[31-i];
    end
end

endmodule