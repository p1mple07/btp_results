module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

    // Combinational logic to reverse the bits of num_in
    always @(num_in) begin
        num_out = {num_in[30], num_in[31], num_in[32-1:2], num_in[1:2]};
    end

endmodule
