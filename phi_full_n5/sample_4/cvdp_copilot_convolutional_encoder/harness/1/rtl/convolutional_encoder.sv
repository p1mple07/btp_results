module convolutional_encoder(
    input clk,
    input rst,
    input data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

    // Shift register to hold previous 2 bits
    reg [1:0] shift_reg;

    // Generator polynomials
    reg [2:0] g1 = 3'b111; // Corresponds to x^2 + x + 1
    reg [2:0] g2 = 3'b101; // Corresponds to x^2 + 1

    // Encoded bit generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 2'b00;
            encoded_bit1 <= 1'b0;
            encoded_bit2 <= 1'b0;
        end else begin
            shift_reg <= {shift_reg[1], shift_reg[0], data_in};
            encoded_bit1 <= g1[shift_reg];
            encoded_bit2 <= g2[shift_reg];
        end
    end

endmodule
