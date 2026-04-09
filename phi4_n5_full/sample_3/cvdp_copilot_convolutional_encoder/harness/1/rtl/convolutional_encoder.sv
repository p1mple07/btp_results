module convolutional_encoder(
    input  logic clk,
    input  logic rst,
    input  logic data_in,
    output logic encoded_bit1,
    output logic encoded_bit2
);

    // 2-bit shift register to hold the previous 2 bits
    logic [1:0] shift_reg;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg   <= 2'b00;
            encoded_bit1<= 1'b0;
            encoded_bit2<= 1'b0;
        end else begin
            // The encoder uses the current input bit and the previous 2 bits.
            // The generator polynomial for g1 (111) produces:
            // encoded_bit1 = data_in XOR shift_reg[0] XOR shift_reg[1]
            // The generator polynomial for g2 (101) produces:
            // encoded_bit2 = data_in XOR shift_reg[1]
            encoded_bit1 <= data_in ^ shift_reg[0] ^ shift_reg[1];
            encoded_bit2 <= data_in ^ shift_reg[1];

            // Update the shift register: shift left and insert the new bit at LSB.
            shift_reg <= {shift_reg[0], data_in};
        end
    end

endmodule