module reverse_bits (
    input [31:0] num_in,
    output [31:0] num_out
);

always @(*) begin
    num_out[31:0] = 0;
    for (integer i = 0; i < 32; i++) begin
        num_out[i] = ~num_in[31 - i];
    end
end

endmodule
