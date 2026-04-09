module convolutional_encoder(
    input clk,
    input rst,
    input data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    // Shift register to hold the previous 2 bits
    reg [1:0] shift_reg;

    // Generator polynomials
    reg [2:0] g1 = 3'b111; // Corresponds to x^2 + x + 1
    reg [2:0] g2 = 3'b101; // Corresponds to x^2 + 1

    // State machine for shifting and encoding
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 2'b00;
            encoded_bit1 <= 0;
            encoded_bit2 <= 0;
        end else begin
            shift_reg <= {shift_reg[1], data_in};

            // Generate encoded_bit1 using g1
            encoded_bit1 <= shift_reg[2] ^ (g1[2] ^ shift_reg[1]);

            // Generate encoded_bit2 using g2
            encoded_bit2 <= shift_reg[1] ^ (g2[2] ^ shift_reg[0]);
        end
    end

endmodule
