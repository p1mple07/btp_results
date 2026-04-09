module convolutional_encoder (
    input  wire clk,
    input  wire rst,
    input  wire data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    // Shift register for constraint length K=3
    // shift_reg[0] holds the oldest bit, shift_reg[2] holds the newest bit
    reg [2:0] shift_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg   <= 3'b000;
            encoded_bit1<= 1'b0;
            encoded_bit2<= 1'b0;
        end else begin
            // Shift left and insert new data bit at LSB (shift_reg[0])
            shift_reg <= {shift_reg[1:0], data_in};

            // Compute encoded outputs using generator polynomials:
            // g1(x) = x^2 + x + 1  --> use all three bits: shift_reg[0] ^ shift_reg[1] ^ shift_reg[2]
            // g2(x) = x^2 + 1      --> use shift_reg[0] and shift_reg[2]
            encoded_bit1 <= shift_reg[0] ^ shift_reg[1] ^ shift_reg[2];
            encoded_bit2 <= shift_reg[0] ^ shift_reg[2];
        end
    end

endmodule