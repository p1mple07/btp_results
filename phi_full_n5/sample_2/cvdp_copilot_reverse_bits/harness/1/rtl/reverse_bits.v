module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

    // Combinational logic to reverse the bits of num_in
    always @ (num_in) begin
        num_out = num_in;
        for (int i = 0; i < 32; i = i + 2) begin
            num_out[31 - i/2] = num_in[i];
        end
    end

endmodule
