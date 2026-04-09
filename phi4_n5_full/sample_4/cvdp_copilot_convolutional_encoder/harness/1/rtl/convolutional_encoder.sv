module convolutional_encoder(
    input  logic clk,
    input  logic rst,
    input  logic data_in,
    output logic encoded_bit1,
    output logic encoded_bit2
);

    // 2-bit shift register to hold the previous two bits.
    // shift_reg[1] holds the older bit, shift_reg[0] holds the newer bit.
    logic [1:0] shift_reg;

    // Shift register update: on each clock edge, shift left and insert new data_in at LSB.
    // Asynchronous reset sets the shift register to 0.
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            shift_reg <= 2'b00;
        else
            shift_reg <= {shift_reg[0], data_in};
    end

    // Generator polynomials:
    // g1(x) = x^2 + x + 1  --> encoded_bit1 = shift_reg[1] ^ shift_reg[0] ^ data_in
    // g2(x) = x^2 + 1      --> encoded_bit2 = shift_reg[1] ^ data_in
    assign encoded_bit1 = shift_reg[1] ^ shift_reg[0] ^ data_in;
    assign encoded_bit2 = shift_reg[1] ^ data_in;

endmodule