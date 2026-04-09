module reverse_bits(
    input [31:0] num_in,
    output reg [31:0] num_out
);

    // Combinational logic to reverse the bits
    always @(*) begin
        num_out = {31'b0, num_in[30:0]};
    end

endmodule
