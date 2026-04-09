module reverse_bits (
    input [31:0] num_in,
    output [31:0] num_out
);
    reg [31:0] num_out;
    integer i;
    for (i = 0; i < 32; i++) begin
        num_out[i] = num_in[31 - i];
    end
endmodule
