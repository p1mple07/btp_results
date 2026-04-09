module convolutional_encoder (
    input  wire         clk,
    input  wire         rst,
    input  wire         data_in,
    output reg          encoded_bit1,
    output reg          encoded_bit2
);

    // Shift register to hold the two previous bits (constraint length k=3 requires 2 memory bits)
    reg [1:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg      <= 2'b00;
            encoded_bit1   <= 1'b0;
            encoded_bit2   <= 1'b0;
        end else begin
            // Compute the encoded bits using the generator polynomials:
            // g1(x) = x^2 + x + 1  --> encoded_bit1 = data_in XOR shift_reg[1] XOR shift_reg[0]
            // g2(x) = x^2 + 1      --> encoded_bit2 = data_in XOR shift_reg[0]
            encoded_bit1  <= data_in ^ shift_reg[1] ^ shift_reg[0];
            encoded_bit2  <= data_in ^ shift_reg[0];

            // Update the shift register:
            // Shift left: the oldest bit (shift_reg[1]) moves to shift_reg[0],
            // and the new input (data_in) becomes the new least significant bit.
            shift_reg <= { shift_reg[0], data_in };
        end
    end

endmodule