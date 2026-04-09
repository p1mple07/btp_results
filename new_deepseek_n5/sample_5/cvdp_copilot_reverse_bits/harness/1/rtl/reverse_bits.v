module reverse_bits(
    input [31:0] num_in,
    output [31:0] num_out
);
    reg [31:0] num_out;
    for (i = 0; i < 32; i = i + 1) begin
        num_out = (num_out << 1) | ((num_in >> (31 - i)) & 1);
    end
endmodule