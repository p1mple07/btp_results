module convolutional_encoder (
    input  wire clk,
    input  wire rst,
    input  wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);
    // Shift register for constraint length K=3 (2 bits of memory)
    reg [1:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg    <= 2'b00;
            encoded_bit1 <= 1'b0;
            encoded_bit2 <= 1'b0;
        end else begin
            // Shift the register: new data_in enters at LSB, MSB becomes oldest bit
            shift_reg <= {shift_reg[0], data_in};

            // Convolutional encoding using generator polynomials:
            // g1(x) = x^2 + x + 1  -> coefficients: [1, 1, 1]
            // g2(x) = x^2 + 1      -> coefficients: [1, 0, 1]
            //
            // With shift_reg[1] as the oldest, shift_reg[0] as the next, and data_in as current,
            // encoded_bit1 = shift_reg[1] XOR shift_reg[0] XOR data_in
            // encoded_bit2 = shift_reg[1] XOR data_in
            encoded_bit1 <= shift_reg[1] ^ shift_reg[0] ^ data_in;
            encoded_bit2 <= shift_reg[1] ^ data_in;
        end
    end
endmodule