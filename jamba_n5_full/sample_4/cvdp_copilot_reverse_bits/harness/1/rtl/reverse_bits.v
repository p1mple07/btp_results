module reverse_bits (
    input [31:0] num_in,
    output [31:0] num_out
);

    reg [31:0] rev;

    always @(*) begin
        rev = 0;
        for (int i = 0; i < 32; i++) begin
            rev = rev | (num_in[31 - i] << i);
        end
    end

endmodule
