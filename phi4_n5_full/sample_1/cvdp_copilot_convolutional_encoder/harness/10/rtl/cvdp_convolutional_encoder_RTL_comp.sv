module convolutional_encoder (
    input  wire         clk,
    input  wire         rst,
    input  wire         data_in,
    output reg          encoded_bit1,
    output reg          encoded_bit2
);

    // Shift register to hold the previous two bits (constraint length k=3)
    // shift_reg[1] holds the oldest bit (s2)
    // shift_reg[0] holds the more recent bit (s1)
    reg [1:0] shift_reg;

    // On each clock cycle, update the shift register and compute the encoded bits.
    // Generator polynomials:
    //   g1(x) = x^2 + x + 1  => encoded_bit1 = s0 XOR s1 XOR s2
    //   g2(x) = x^2 + 1      => encoded_bit2 = s0 XOR s2
    // Here, s0 is the current input (data_in), s1 is shift_reg[0], and s2 is shift_reg[1].
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg      <= 2'b00;
            encoded_bit1   <= 1'b0;
            encoded_bit2   <= 1'b0;
        end else begin
            // Shift the register: the new input becomes the least significant bit.
            shift_reg <= {shift_reg[0], data_in};

            // Compute encoded outputs based on generator polynomials.
            encoded_bit1 <= data_in ^ shift_reg[0] ^ shift_reg[1];
            encoded_bit2 <= data_in ^ shift_reg[1];
        end
    end

endmodule