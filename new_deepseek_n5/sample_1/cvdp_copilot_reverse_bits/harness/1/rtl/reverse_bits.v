module reverse_bits(
    input [31:0] num_in,
    output [31:0] num_out
);

    integer i;

    for (i = 0; i < 32; i = i + 1) begin
        num_out = num_out | ((num_in >> i) << (31 - i));
    end

endmodule