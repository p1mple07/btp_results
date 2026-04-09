module convolutional_encoder (
    input clk,
    input rst,
    input data_in,
    output reg encoded_bit1,
    output reg encoded_bit2
);

// Shift register to hold previous 2 bits
reg [1:0] shift_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        shift_reg <= 2'b00; // Reset shift register
        encoded_bit1 <= 0; // Reset encoded bits
        encoded_bit2 <= 0;
    end else begin
        shift_reg <= {shift_reg[1], shift_reg[0], data_in}; // Shift register

        // Generate encoded bits using generator polynomials
        encoded_bit1 <= shift_reg[2] ^ shift_reg[1] ^ shift_reg[0];
        encoded_bit2 <= shift_reg[2] ^ shift_reg[1];
    end
end

endmodule
