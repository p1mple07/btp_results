module convolutional_encoder(
    input clk,
    input rst,
    input data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    // Shift register to hold previous bits
    reg [1:0] shift_reg;

    // Encoded bits
    reg encoded_bit1_reg;
    reg encoded_bit2_reg;

    // Encoding logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 2'b00;
            encoded_bit1_reg <= 0;
            encoded_bit2_reg <= 0;
        end else begin
            shift_reg <= {shift_reg[1], shift_reg[0], data_in};

            // Generate encoded_bit1 using g1(x) = x^2 + x + 1
            encoded_bit1_reg = shift_reg[2] ^ shift_reg[1] ^ shift_reg[0];

            // Generate encoded_bit2 using g2(x) = x^2 + 1
            encoded_bit2_reg = shift_reg[2] ^ shift_reg[1];
        end

        encoded_bit1 <= encoded_bit1_reg;
        encoded_bit2 <= encoded_bit2_reg;
    end

endmodule
